use darkshuffle::models::config::{GameSettings};

#[starknet::interface]
trait IGameContract<T> {
    fn mint(ref self: T, settings_id: u32);
    fn enter_season(ref self: T, game_id: u128, season_id: u32);
    fn start_game(ref self: T, game_id: u128, name: felt252);
    fn abandon_game(ref self: T, game_id: u128);
    fn score(ref self: T, game_id: u128) -> u16;
    fn get_settings(ref self: T, settings_id: u32) -> GameSettings;
    fn is_valid_settings(ref self: T, settings_id: u32) -> bool;
}

#[dojo::contract]
mod game_systems {
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
    use starknet::{get_caller_address, get_tx_info};

    use darkshuffle::constants::{WORLD_CONFIG_ID, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID, DEFAULT_NS, LAST_NODE_DEPTH};
    use darkshuffle::models::game::{Game, GameState, GameOwnerTrait};
    use darkshuffle::models::draft::{Draft};
    use darkshuffle::models::config::{WorldConfig, GameSettings};
    use darkshuffle::models::season::{Season, SeasonOwnerTrait};
    use darkshuffle::utils::{
        season::SeasonUtilsImpl,
        draft::DraftUtilsImpl,
        random
    };

    #[abi(embed_v0)]
    impl GameContractImpl of super::IGameContract<ContractState> {
        fn mint(ref self: ContractState, settings_id: u32) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let settings: GameSettings = world.read_model(settings_id);
            assert(settings.start_health != 0, 'Invalid settings');

            let mut world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            world_config.game_count += 1;
            world.write_model(@world_config);

            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            game_token.mint(get_caller_address(), world_config.game_count.into(), settings_id);
        }

        fn enter_season(ref self: ContractState, game_id: u128, season_id: u32) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut season: Season = world.read_model(season_id);
            assert(season.is_active(), 'Season not active');

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };

            let settings_id = game_token.settings_id(game_id.into());
            assert(settings_id == season.settings_id, 'Invalid settings');


            let fee_distribution = season.entry_amount / 100 * 5;
            let season_distribution = season.entry_amount / 100 * 90;

            let chain_id = get_tx_info().unbox().chain_id;
            let payment_dispatcher = IERC20Dispatcher { contract_address: SeasonUtilsImpl::get_lords_address(chain_id) };
            // veLORDS
            payment_dispatcher.transfer_from(get_caller_address(), SeasonUtilsImpl::get_velords_address(chain_id), fee_distribution);
            // PG FEE
            payment_dispatcher.transfer_from(get_caller_address(), SeasonUtilsImpl::get_pg_address(chain_id), fee_distribution);
            // SEASON POOL
            payment_dispatcher.transfer_from(get_caller_address(), season.season_address, season_distribution);

            season.reward_pool += season_distribution;
            world.write_model(@season);

            game_token.attach_season_pass(game_id.into(), season_id);
        }

        fn start_game(ref self: ContractState, game_id: u128, name: felt252) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            let game_settings: GameSettings = world.read_model(game_token.settings_id(game_id.into()));

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let options = DraftUtilsImpl::get_draft_options(seed); 

            world.write_model(@Game {
                game_id,
                season_id: game_token.season_pass(game_id.into()),
                player_name: name,
                state: GameState::Draft,    

                hero_health: game_settings.start_health,
                hero_xp: 1,
                monsters_slain: 0,

                map_level: 0,
                map_depth: LAST_NODE_DEPTH,
                last_node_id: 0,
            });

            world.write_model(@Draft {
                game_id,
                options,
                cards: array![].span()
            });
        }

        fn abandon_game(ref self: ContractState, game_id: u128) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);

            game.state = GameState::Over;
            game.hero_health = 0;

            let mut season: Season = world.read_model(game.season_id);
            if season.season_id != 0 && season.is_active() {
                SeasonUtilsImpl::score_game(ref world, game);
            }

            world.write_model(@game);
        }

        fn score(ref self: ContractState, game_id: u128) -> u16 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp
        }

        fn get_settings(ref self: ContractState, settings_id: u32) -> GameSettings {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings
        }

        fn is_valid_settings(ref self: ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.start_health != 0
        }
    }
}
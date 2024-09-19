import InfoIcon from '@mui/icons-material/Info';
import PersonIcon from '@mui/icons-material/Person';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import { LoadingButton } from '@mui/lab';
import { Box, Button, Typography } from '@mui/material';
import { useConnect } from "@starknet-react/core";
import React, { useContext, useState } from 'react';
import { Link } from "react-router-dom";
import { dojoConfig } from '../../dojo.config';
import { DojoContext } from '../contexts/dojoContext';
import { DraftContext } from '../contexts/draftContext';
import { ellipseAddress } from '../helpers/utilities';
import ChooseName from './dialogs/chooseName';
import TutorialDialog from './dialogs/tutorial';
import ProfileMenu from './header/profileMenu';
import logo from '../assets/images/logo.svg';

const menuItems = [
  {
    name: 'Play Season',
    path: '/',
    icon: <InfoIcon />
  },
]

function Header(props) {
  const { connect, connectors } = useConnect();
  let cartridgeConnector = connectors.find(conn => conn.id === "controller")
  
  const dojo = useContext(DojoContext)
  const draft = useContext(DraftContext)

  const [nameDialog, openNameDialog] = useState(false)
  const [tutorial, openTutorial] = useState(false)

  const [anchorEl, setAnchorEl] = useState(null);

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  return (
    <Box sx={styles.header}>

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
        <Box height={32} sx={{ opacity: 1 }}>
          <img alt='' src={logo} height='32' />
        </Box>

        {menuItems.map(item => {
          return <Link to={item.path} key={item.name} sx={styles.item}>
            <Box sx={styles.content}>
              <Typography>
                {item.name}
              </Typography>
            </Box>
          </Link>
        })}

        {/* <Button onClick={() => { openTutorial(true) }}>Tutorial</Button> */}
      </Box>

      <Box>
        {dojo.address
          ? <Button onClick={handleClick} endIcon={<PersonIcon fontSize='large' />} size='large'>
            <Typography color='primary' sx={{ fontSize: '12px' }}>
              {ellipseAddress(dojo.address, 4, 4)}
            </Typography>
          </Button>

          : <LoadingButton loading={dojo.connecting} variant='outlined' onClick={() => connect({ connector: cartridgeConnector })} size='large' startIcon={<SportsEsportsIcon />}>
            <Typography color='primary'>
              Connect
            </Typography>
          </LoadingButton>
        }
      </Box>

      <ProfileMenu handleClose={handleClose} anchorEl={anchorEl} openNameDialog={openNameDialog} />
      <ChooseName open={nameDialog} close={openNameDialog} />
      <TutorialDialog open={tutorial} close={openTutorial} />
    </Box>
  );
}

export default Header

const styles = {
  header: {
    width: '100%',
    height: '55px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.12)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    px: 2,
    pl: 3,
    boxSizing: 'border-box',
    gap: 4
  },
  item: {
    letterSpacing: '1px',
  },
  logo: {
    cursor: 'pointer',
    height: '100%',
  },
  content: {
    textDecoration: 'none',
    color: 'white',
  },
  menu: {
    width: 300
  }
};
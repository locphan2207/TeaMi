import React from 'react';
import { ProtectedRoute } from '../../util/route_util';
import LogoutContainer from '../logout/logout_container';
import TiEdit from 'react-icons/lib/ti/edit';

const Nav = (props) => {
  return (
    <nav className="navbar">
      <ProtectedRoute path="/chats" component={LogoutContainer} />
      <div className="nav-greeting">
        <div>
          <p>
            TeaMí
          </p>
        </div>
        <div className="nav-username">
          <p>
            {props.currentUser.username}
          </p>
        </div>
      </div>
      <button onClick={() => {
        if(props.history.path !== '/new') {
          props.clearChatHighlight();
        }
      }}>
        <TiEdit size={30} color={`#7DCC4D`}/>
      </button>
    </nav>
  );
};

export default Nav;
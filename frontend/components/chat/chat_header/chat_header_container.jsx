import React from 'react';
import FaInfoCircle from 'react-icons/lib/fa/info-circle';
// import { withRouter } from 'react-router-dom';
// import { connect } from  'react-redux';
// import ChatHeader from './chat_header';

// const mapStateToProps = (state, ownProps) => ({
  
// });

// const mapDispatchToProps = (state, ownProps) => ({

// });

// export default withRouter(
//   connect(
//     mapStateToProps,
//     mapDispatchToProps
//   )(ChatHeader)
// );

const ChatHeaderContainer = ({ chat, toggleChatInfo }) => (
  <div className="chat-header">
    <p>{chat.name}</p>
    <button onClick={() => toggleChatInfo()}><FaInfoCircle size={30} color={`#7DCC4D`} /></button>
  </div>
);

export default ChatHeaderContainer;
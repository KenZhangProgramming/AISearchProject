import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import "./ChatHistory.css";

export type ChatHistoryProps = {
  history: {prompt: string, response: string}[];
  showInProgress?: boolean;
};

export const ChatHistory = ({history = [], showInProgress = false } : ChatHistoryProps) => {

  const linkRenderer = (props: any) => {
    return (
      <a href={props.href} target="_blank" rel="noreferrer">
        {props.children}
      </a>
    );
  }

  return history.map((item, index) => (
    <div className="response" key={index}>
      <div><b>You:</b> {item.prompt}</div>
      <div>
        <b>AI:</b> 
        <ReactMarkdown components={{ a:linkRenderer}} remarkPlugins={[remarkGfm]}>{item.response}</ReactMarkdown> 
        {showInProgress && <div className='thinking-indicator'/>}
      </div>
    </div>
  ));
}

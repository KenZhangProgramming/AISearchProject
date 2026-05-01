import { ChatBubble } from './ChatBubble';
import type { ChatMessage } from './types';
import styles from './ChatThread.module.css';

type ChatThreadProps = {
  messages: ChatMessage[];
};

export function ChatThread({ messages }: ChatThreadProps) {
  if (messages.length === 0) {
    return null;
  }
  return (
    <ol className={styles.thread} aria-label="Conversation">
      {messages.map((message) => (
        <ChatBubble key={message.id} role={message.role}>
          {message.content}
        </ChatBubble>
      ))}
    </ol>
  );
}

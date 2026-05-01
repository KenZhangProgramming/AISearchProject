import type { ReactNode } from 'react';
import type { ChatRole } from './types';
import styles from './ChatBubble.module.css';

type ChatBubbleProps = {
  role: ChatRole;
  children: ReactNode;
};

export function ChatBubble({ role, children }: ChatBubbleProps) {
  const roleClass = role === 'user' ? styles.user : styles.assistant;
  return <li className={`${styles.bubble} ${roleClass}`}>{children}</li>;
}

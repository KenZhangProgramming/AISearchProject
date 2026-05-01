import { useCallback, useState } from 'react';
import type { ChatMessage } from './types';

export function useChat() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);

  const addUserMessage = useCallback((content: string) => {
    const trimmed = content.trim();
    if (!trimmed) {
      return;
    }
    const message: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'user',
      content: trimmed,
      createdAt: Date.now(),
    };
    setMessages((prev) => [...prev, message]);
  }, []);

  return { messages, addUserMessage };
}

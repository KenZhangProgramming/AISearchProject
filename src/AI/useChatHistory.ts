import { useState, useCallback } from 'react';

export type ChatMessage = {
  prompt: string;
  response: string;
};

export const useChatHistory = () => {
  const [history, setHistory] = useState<ChatMessage[]>([]);
  const [currentQuestion, setCurrentQuestion] = useState<string>('');
  const [currentAnswer, setCurrentAnswer] = useState<string>('');

  const addToHistory = useCallback(() => {
    if (currentQuestion) {
      setHistory((prev) => [
        { prompt: currentQuestion, response: currentAnswer },
        ...prev,
      ]);
      setCurrentAnswer('');
      setCurrentQuestion('');
    }
  }, [currentQuestion, currentAnswer]);

  const startNewQuestion = useCallback((question: string) => {
    setCurrentQuestion(question);
    setCurrentAnswer('');
  }, []);

  const updateCurrentAnswer = useCallback((answer: string) => {
    setCurrentAnswer(answer);
  }, []);

  const getHistoryForRequest = useCallback(
    (maxItems: number = 5) => {
      // Create a copy and reverse to get most recent items
      const reversedHistory = [...history].reverse();
      const recentHistory = reversedHistory.slice(0, maxItems).map((item) => ({
        Question: item.prompt,
        Answer: item.response,
      }));

      if (currentQuestion) {
        recentHistory.push({
          Question: currentQuestion,
          Answer: currentAnswer,
        });
      }

      return recentHistory;
    },
    [history, currentQuestion, currentAnswer]
  );

  return {
    history,
    currentQuestion,
    currentAnswer,
    addToHistory,
    startNewQuestion,
    updateCurrentAnswer,
    getHistoryForRequest,
  };
};

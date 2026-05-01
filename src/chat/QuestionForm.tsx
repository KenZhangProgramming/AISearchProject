import { useState, type FormEvent } from 'react';
import styles from './QuestionForm.module.css';

type QuestionFormProps = {
  onAsk: (question: string) => void;
  disabled?: boolean;
};

export function QuestionForm({ onAsk, disabled = false }: QuestionFormProps) {
  const [question, setQuestion] = useState('');

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const trimmed = question.trim();
    if (!trimmed || disabled) {
      return;
    }
    onAsk(trimmed);
    setQuestion('');
  };

  const isEmpty = question.trim().length === 0;

  return (
    <form className={styles.form} onSubmit={handleSubmit}>
      <label className={styles.srOnly} htmlFor="client-question">
        Ask your banking question
      </label>
      <input
        id="client-question"
        name="question"
        type="text"
        className={styles.input}
        placeholder="Ask a question about your banking data..."
        autoComplete="off"
        value={question}
        onChange={(event) => setQuestion(event.target.value)}
        disabled={disabled}
      />
      <button
        type="submit"
        className={styles.button}
        disabled={disabled || isEmpty}
        aria-disabled={disabled || isEmpty}
      >
        Ask
      </button>
    </form>
  );
}

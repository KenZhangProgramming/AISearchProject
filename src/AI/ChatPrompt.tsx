type ChatPromptProps = {
  value: string;
  onChange: (value: string) => void;
  onSubmit: () => void;
  disabled?: boolean;
};

export const ChatPrompt = ({ value, onChange, onSubmit, disabled }: ChatPromptProps) => {
  const handleKeyDown = (event: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (event.key === 'Enter' && !event.shiftKey && !disabled) {
      event.preventDefault();
      onSubmit();
    }
  };

  return (
    <div className="prompt-container">
      <textarea
        className="prompt"
        value={value}
        id="prompt"
        onKeyDown={handleKeyDown}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
      />
    </div>
  );
};

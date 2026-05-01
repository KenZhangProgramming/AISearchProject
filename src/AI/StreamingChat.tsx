import { useState, useEffect, useRef, useCallback } from "react";
import "./Chat.css";
import "./StreamingChat.css";
import { ChatHistory } from "./ChatHistory";
import { useChatCompletion } from "./useChatCompletion";
import { useChatHistory } from "./useChatHistory";
import { ChatPrompt } from "./ChatPrompt";
import { ErrorMessage } from "./ErrorMessage";

export type StreamingChatProps = {
  pageTitle: string;
  apiUrl: string;
  apiScope: string;
  instructionText: string;
  enableLanguageSelector?: boolean;
  extraRequestParameters?: Record<string, string>;
};

export const StreamingChat = (props: StreamingChatProps) => {
  const [dropdownValues, setDropdownValues] = useState<Record<string, string>>({});
  const [promptText, setPromptText] = useState('');
  const [inputLanguage, setInputLanguage] = useState<string>('en-CA');
  const [outputNextAnswerToSpeech, setOutputNextAnswerToSpeech] = useState(false);

  const {
    history,
    currentQuestion,
    currentAnswer,
    addToHistory,
    startNewQuestion,
    updateCurrentAnswer,
    getHistoryForRequest,
  } = useChatHistory();

  const { sendRequest, isLoading, error } = useChatCompletion({
    apiUrl: props.apiUrl,
    apiScope: props.apiScope,
    onResponseChunk: (chunk) => updateCurrentAnswer(chunk),
    onComplete: (fullResponse, voiceName, voiceStyle) => {
      if (outputNextAnswerToSpeech) {
        textToSpeech(fullResponse, voiceName ?? null, voiceStyle ?? null);
        setOutputNextAnswerToSpeech(false);
      }
    },
  });

  // Initialize dropdown values from options
  useEffect(() => {
    if (props.options) {
      const initialValues = props.options.reduce((acc: Record<string, string>, option) => {
        acc[option.key] = option.list[0].key || '';
        return acc;
      }, {});
      setDropdownValues(initialValues);
    }
  }, [props.options]);

  const handleSubmit = useCallback(
    async (question: string) => {
      if (!question.trim()) return;

      // Save current conversation to history if exists
      addToHistory();

      // Start new question
      startNewQuestion(question);
      setPromptText('');

      // Prepare request body
      const requestBody = {
        history: getHistoryForRequest(5),
        prompt: question,
        ...dropdownValues,
        ...(props.extraRequestParameters ?? {}),
      };

      // Send request
      await sendRequest(requestBody);
    },
    [
      addToHistory,
      startNewQuestion,
      getHistoryForRequest,
      dropdownValues,
      props.extraRequestParameters,
      sendRequest,
    ]
  );

  const handleAskQuestion = useCallback(() => {
    handleSubmit(promptText);
  }, [promptText, handleSubmit]);

  const handleOptionDropdownChange = useCallback((key: string, value: string) => {
    setDropdownValues((prevValues) => ({
      ...prevValues,
      [key]: value,
    }));
  }, []);

  return (
    <>
      <PageHeader title={props.pageTitle} />
      <div className="page-content">
        <div className="instructions">{props.instructionText}</div>

        <ChatOptions
          enableLanguageSelector={props.enableLanguageSelector}
          currentLanguage={inputLanguage}
          onLanguageChange={setInputLanguage}
          options={props.options}
          dropdownValues={dropdownValues}
          onOptionChange={handleOptionDropdownChange}
        />

        <ChatPrompt
          value={promptText}
          onChange={setPromptText}
          onSubmit={handleAskQuestion}
          disabled={isLoading}
        />

        <div className="history">
          <ErrorMessage error={error} />
          {currentAnswer && (
            <ChatHistory
              history={[{ prompt: currentQuestion, response: currentAnswer }]}
              showInProgress={isLoading}
            />
          )}
          <ChatHistory history={history} />
        </div>
      </div>
    </>
  );
};

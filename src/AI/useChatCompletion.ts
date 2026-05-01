import { InteractionRequiredAuthError } from "@azure/msal-browser";
import { useMsal } from "@azure/msal-react";
import { useState } from "react";

export type CompletionRequest = {
  prompt: string;
  history: { Question: string; Answer: string }[];
  [key: string]: any;
};

export type UseChatCompletionProps = {
  apiUrl: string;
  apiScope: string;
  onResponseChunk?: (chunk: string) => void;
  onComplete?: (fullResponse: string, voiceName?: string | null, voiceStyle?: string | null) => void;
};

export const useChatCompletion = ({
  apiUrl,
  apiScope,
  onResponseChunk,
  onComplete,
}: UseChatCompletionProps) => {
  const { instance, accounts } = useMsal();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const sendRequest = async (requestBody: CompletionRequest) => {
    setIsLoading(true);
    setError(null);

    try {
      let tokenResponse = null;
      try {
        const tokenRequest = {
          scopes: [apiScope],
          account: accounts[0],
        };
        tokenResponse = await instance.acquireTokenSilent(tokenRequest);
      } catch (error) {
        if (error instanceof InteractionRequiredAuthError) {
          const tokenRequest = {
            scopes: [apiScope],
            account: accounts[0],
          };
          tokenResponse = await instance.acquireTokenPopup(tokenRequest);
        } else {
          throw error;
        }
      }

      const response = await fetch(apiUrl, {
        method: 'POST',
        body: JSON.stringify(requestBody),
        headers: {
          Authorization: `Bearer ${tokenResponse?.accessToken}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.body) {
        throw Error("ReadableStream not yet supported in this browser.");
      }

      const reader = response.body.getReader();
      const textDecoder = new TextDecoder();
      let answer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) {
          const voiceName = response.headers.get('Voice-Name');
          const voiceStyle = response.headers.get('Voice-Style');
          onComplete?.(answer, voiceName, voiceStyle);
          return answer;
        }

        answer += textDecoder.decode(value);
        onResponseChunk?.(answer);
      }
    } catch (err) {
      setError(err as Error);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    sendRequest,
    isLoading,
    error,
  };
};

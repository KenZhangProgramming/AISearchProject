import { ReactNode } from "react";

type ErrorMessageProps = {
  error: any | null;
};

export const ErrorMessage = ({ error }: ErrorMessageProps): ReactNode => {
  if (!error) {
    return null;
  }

  if (error.code === "ERR_NETWORK") {
    return (
      <div>
        Hmmmm, I can't talk to my brain. You probably have a bad internet
        connection. Try again soon.
      </div>
    );
  }

  if (error.code === "ERR_BAD_REQUEST" && error.response?.status === 429) {
    return (
      <div>
        You're asking too much of me. Let me take a break and ask again in about
        a minute.
      </div>
    );
  }

  return <div>Uh oh, I've fallen and I can't get up.</div>;
};

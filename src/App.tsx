import './App.css'
import { QuestionForm } from './chat/QuestionForm'
import { ChatThread } from './chat/ChatThread'
import { useChat } from './chat/useChat'

function App() {
  const { messages, addUserMessage } = useChat()

  return (
    <main className="app-shell">
      <section className="hero-panel" aria-label="Bank AI Search main page">
        <h1>Bank AI Search</h1>
        <QuestionForm onAsk={addUserMessage} />
        <ChatThread messages={messages} />
      </section>
    </main>
  )
}

export default App

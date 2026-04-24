import './App.css'

function App() {
  const onSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
  }

  return (
    <main className="app-shell">
      <section className="hero-panel" aria-label="Bank AI Search main page">
        <h1>Bank AI Search</h1>
        <form className="question-form" onSubmit={onSubmit}>
          <label className="sr-only" htmlFor="client-question">
            Ask your banking question
          </label>
          <input
            id="client-question"
            name="question"
            type="text"
            placeholder="Ask a question about your banking data..."
            autoComplete="off"
          />
          <button type="submit">Search</button>
        </form>
      </section>
    </main>
  )
}

export default App

import { useState } from "react";
import type { FormEvent } from "react";

interface TaskFormProps {
  onCreate: (title: string) => Promise<void>;
  disabled: boolean;
}

export function TaskForm({ onCreate, disabled }: TaskFormProps) {
  const [title, setTitle] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmedTitle = title.trim();
    if (!trimmedTitle) {
      return;
    }

    setSubmitting(true);
    try {
      await onCreate(trimmedTitle);
      setTitle("");
    } finally {
      setSubmitting(false);
    }
  }

  const isDisabled = disabled || submitting;

  return (
    <form className="task-form" onSubmit={handleSubmit}>
      <div>
        <label htmlFor="task-title">Task title</label>
        <input
          id="task-title"
          name="task-title"
          type="text"
          value={title}
          onChange={(event) => setTitle(event.target.value)}
          required
          disabled={isDisabled}
        />
      </div>
      <button type="submit" disabled={isDisabled || title.trim().length === 0}>
        Add Task
      </button>
    </form>
  );
}

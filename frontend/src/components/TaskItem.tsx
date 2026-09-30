import { useEffect, useRef } from "react";
import type { Task } from "../types/task";

interface TaskItemProps {
  task: Task;
  onToggleStatus: (task: Task) => void;
  onDelete: (task: Task) => void;
  onStartEdit: (task: Task) => void;
  onCancelEdit: () => void;
  disabled: boolean;
  isEditing: boolean;
}

export function TaskItem({ task, onToggleStatus, onDelete, onStartEdit, onCancelEdit, disabled, isEditing }: TaskItemProps) {
  const isCompleted = task.status === "COMPLETED";
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isEditing) {
      inputRef.current?.focus();
    }
  }, [isEditing]);

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Escape") {
      onCancelEdit();
    }
  }

  return (
    <li className={`task-item${isCompleted ? " task-item--completed" : ""}`}>
      {isEditing ? (
        <input
          ref={inputRef}
          className="task-item__edit-input"
          type="text"
          defaultValue={task.title}
          aria-label={`Edit title for task: ${task.title}`}
          onKeyDown={handleKeyDown}
        />
      ) : (
        <span className="task-item__title">{task.title}</span>
      )}
      {isCompleted && !isEditing && <span className="task-item__badge">Completed</span>}
      <div className="task-item__actions">
        {!isEditing && (
          <button
            type="button"
            aria-label={`Edit ${task.title}`}
            onClick={() => onStartEdit(task)}
            disabled={disabled}
          >
            Edit
          </button>
        )}
        <button
          type="button"
          onClick={() => onToggleStatus(task)}
          disabled={disabled || isEditing}
        >
          {isCompleted ? "Mark Open" : "Mark Complete"}
        </button>
        <button
          type="button"
          onClick={() => onDelete(task)}
          disabled={disabled || isEditing}
        >
          Delete
        </button>
      </div>
    </li>
  );
}

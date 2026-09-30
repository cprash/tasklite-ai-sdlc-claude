import type { Task } from "../types/task";

interface TaskItemProps {
  task: Task;
  onToggleStatus: (task: Task) => void;
  onDelete: (task: Task) => void;
  disabled: boolean;
}

export function TaskItem({ task, onToggleStatus, onDelete, disabled }: TaskItemProps) {
  const isCompleted = task.status === "COMPLETED";

  return (
    <li className={`task-item${isCompleted ? " task-item--completed" : ""}`}>
      <span className="task-item__title">{task.title}</span>
      {isCompleted && <span className="task-item__badge">Completed</span>}
      <div className="task-item__actions">
        <button type="button" onClick={() => onToggleStatus(task)} disabled={disabled}>
          {isCompleted ? "Mark Open" : "Mark Complete"}
        </button>
        <button type="button" onClick={() => onDelete(task)} disabled={disabled}>
          Delete
        </button>
      </div>
    </li>
  );
}

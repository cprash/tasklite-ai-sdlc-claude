import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe, toHaveNoViolations } from "jest-axe";
import { TaskItem } from "./TaskItem";
import type { Task } from "../types/task";

expect.extend(toHaveNoViolations);

const mockTask: Task = {
  id: 1,
  title: "Buy milk",
  status: "OPEN",
  createdAt: "2026-10-01T00:00:00.000Z",
  updatedAt: "2026-10-01T00:00:00.000Z",
};

function renderItem(overrides: Partial<React.ComponentProps<typeof TaskItem>> = {}) {
  const props = {
    task: mockTask,
    onToggleStatus: vi.fn(),
    onDelete: vi.fn(),
    onStartEdit: vi.fn(),
    onCancelEdit: vi.fn(),
    disabled: false,
    isEditing: false,
    ...overrides,
  };
  return { ...render(<TaskItem {...props} />), props };
}

describe("TaskItem — view mode", () => {
  it("renders the task title", () => {
    renderItem();
    expect(screen.getByText("Buy milk")).toBeInTheDocument();
  });

  it("renders the Edit button with an accessible name", () => {
    renderItem();
    expect(screen.getByRole("button", { name: "Edit Buy milk" })).toBeInTheDocument();
  });

  it("calls onStartEdit with the task when Edit is clicked", async () => {
    const { props } = renderItem();
    await userEvent.click(screen.getByRole("button", { name: "Edit Buy milk" }));
    expect(props.onStartEdit).toHaveBeenCalledWith(mockTask);
  });

  it("has no accessibility violations in view mode", async () => {
    const { container } = renderItem();
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});

describe("TaskItem — edit mode", () => {
  it("renders a text input prefilled with the task title", () => {
    renderItem({ isEditing: true });
    const input = screen.getByRole("textbox", { name: /edit title for task: buy milk/i });
    expect(input).toBeInTheDocument();
    expect(input).toHaveValue("Buy milk");
  });

  it("hides the Edit button in edit mode", () => {
    renderItem({ isEditing: true });
    expect(screen.queryByRole("button", { name: /edit buy milk/i })).not.toBeInTheDocument();
  });

  it("disables Toggle and Delete buttons while editing", () => {
    renderItem({ isEditing: true });
    expect(screen.getByRole("button", { name: /mark complete/i })).toBeDisabled();
    expect(screen.getByRole("button", { name: /delete/i })).toBeDisabled();
  });

  it("calls onCancelEdit when Escape is pressed in the input", async () => {
    const { props } = renderItem({ isEditing: true });
    const input = screen.getByRole("textbox");
    await userEvent.type(input, "{Escape}");
    expect(props.onCancelEdit).toHaveBeenCalledTimes(1);
  });

  it("has no accessibility violations in edit mode", async () => {
    const { container } = renderItem({ isEditing: true });
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});

describe("TaskItem — mutual exclusion (via isEditing prop)", () => {
  it("shows title span when isEditing is false", () => {
    renderItem({ isEditing: false });
    expect(screen.getByText("Buy milk")).toBeInTheDocument();
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
  });

  it("shows input when isEditing is true", () => {
    renderItem({ isEditing: true });
    expect(screen.queryByText("Buy milk")).not.toBeInTheDocument();
    expect(screen.getByRole("textbox")).toBeInTheDocument();
  });
});

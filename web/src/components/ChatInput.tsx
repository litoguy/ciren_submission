import { useState, useRef, useEffect } from "react";
import { Send, Paperclip } from "lucide-react";

interface ChatInputProps {
  onSend: (message: string) => void;
  isLoading: boolean;
  initialValue?: string;
}

const ChatInput = ({ onSend, isLoading, initialValue = "" }: ChatInputProps) => {
  const [value, setValue] = useState(initialValue);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    if (initialValue) setValue(initialValue);
  }, [initialValue]);

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = "auto";
      textareaRef.current.style.height = Math.min(textareaRef.current.scrollHeight, 160) + "px";
    }
  }, [value]);

  const handleSubmit = () => {
    if (!value.trim() || isLoading) return;
    onSend(value.trim());
    setValue("");
  };

  return (
    <div className="w-full max-w-2xl mx-auto px-4 pb-4">
      <div className="relative rounded-2xl border-[0.5px] border-border bg-card shadow-sm focus-within:border-primary/50 focus-within:shadow-md transition-all">
        <textarea
          ref={textareaRef}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              handleSubmit();
            }
          }}
          placeholder="Ask anything about Central University..."
          rows={1}
          className="w-full resize-none bg-transparent px-4 pt-4 pb-12 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none"
        />
        <div className="absolute bottom-2 left-2 right-2 flex items-center justify-between">
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors rounded-lg hover:bg-muted">
            <Paperclip className="w-3.5 h-3.5" />
            Attach
          </button>
          <div className="flex items-center gap-2">
            <span className="text-[11px] text-muted-foreground">{value.length} / 3,000</span>
            <button
              onClick={handleSubmit}
              disabled={!value.trim() || isLoading}
              className="w-8 h-8 rounded-lg bg-primary text-primary-foreground flex items-center justify-center hover:bg-primary-light disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            >
              <Send className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
      <p className="text-center text-[11px] text-muted-foreground mt-2">
        CU Chat may generate inaccurate information. Always verify with official university sources.
      </p>
    </div>
  );
};

export default ChatInput;

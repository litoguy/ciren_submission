import { BookOpen, FileText, MapPin, Calendar } from "lucide-react";

interface ChatWelcomeProps {
  onSuggestionClick: (text: string) => void;
}

const suggestions = [
  { icon: BookOpen, label: "Course help", prompt: "Help me understand my course material", color: "bg-gold-pale text-primary" },
  { icon: FileText, label: "Write an essay", prompt: "Help me write an academic essay", color: "bg-accent text-accent-foreground" },
  { icon: MapPin, label: "Campus info", prompt: "Tell me about campus facilities and locations", color: "bg-secondary text-secondary-foreground" },
  { icon: Calendar, label: "Exam prep", prompt: "Help me prepare for my upcoming exams", color: "bg-gold-pale text-primary-light" },
];

const ChatWelcome = ({ onSuggestionClick }: ChatWelcomeProps) => {
  return (
    <div className="flex-1 flex flex-col items-center justify-center px-6 max-w-2xl mx-auto">
      <div className="w-16 h-16 rounded-2xl flex items-center justify-center mb-6">
        <img src="/logo.png" alt="Logo" className="w-full h-full object-cover" />
      </div>

      <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-3 text-center">
        Welcome to CU Chat
      </h2>
      <p className="text-muted-foreground text-center mb-10 max-w-md">
        Your AI assistant for Central University. Ask about courses, campus life, assignments, and more.
      </p>

      <div className="grid grid-cols-2 gap-3 w-full max-w-lg">
        {suggestions.map(({ icon: Icon, label, prompt, color }) => (
          <button
            key={label}
            onClick={() => onSuggestionClick(prompt)}
            className="flex items-center gap-3 px-4 py-3.5 rounded-xl border-[0.5px] border-border bg-card hover:shadow-md hover:border-primary/30 transition-all text-left group"
          >
            <div className={`w-9 h-9 rounded-lg ${color} flex items-center justify-center shrink-0`}>
              <Icon className="w-4 h-4" />
            </div>
            <span className="text-sm font-medium text-foreground">{label}</span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default ChatWelcome;

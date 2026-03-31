import { MessageSquarePlus, History, Settings, GraduationCap, BookOpen, HelpCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { Link, useLocation, useNavigate } from "react-router-dom";

interface ChatHistory {
  id: string;
  title: string;
  preview: string;
}

interface ChatSidebarProps {
  chatHistory: ChatHistory[];
  activeChatId: string | null;
  onNewChat: () => void;
  onSelectChat: (id: string) => void;
  isOpen: boolean;
}

const ChatSidebar = ({ chatHistory, activeChatId, onNewChat, onSelectChat, isOpen }: ChatSidebarProps) => {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <aside
      className={cn(
        "flex flex-col h-full bg-sidebar text-sidebar-foreground transition-all duration-300 border-r border-sidebar-border",
        isOpen ? "w-72" : "w-0 overflow-hidden"
      )}
    >
      {/* Logo */}
      <Link to="/" className="flex items-center gap-3 px-5 py-5 border-b border-sidebar-border">
        <div className="w-9 h-9 rounded-lg bg-white flex items-center justify-center overflow-hidden">
          <img src="/logo.png" alt="Logo" className="w-full h-full object-cover" />
        </div>
        <div>
          <h1 className="font-bold text-sm tracking-tight text-sidebar-foreground">CU Chat</h1>
          <p className="text-[11px] text-sidebar-foreground/60">Central University AI</p>
        </div>
      </Link>

      {/* New Chat */}
      <div className="px-3 pt-4 pb-2">
        <button
          onClick={() => {
            onNewChat();
            if (location.pathname !== "/") {
              navigate("/");
            }
          }}
          className="flex items-center gap-2 w-full px-3 py-2.5 rounded-lg bg-sidebar-accent text-sidebar-accent-foreground hover:bg-primary hover:text-primary-foreground transition-colors text-sm font-medium"
        >
          <MessageSquarePlus className="w-4 h-4" />
          New Chat
        </button>
      </div>

      {/* Nav */}
      <nav className="px-3 py-2 space-y-0.5">
        {[
          { icon: BookOpen, label: "Academic Help", path: "/academic" },
          { icon: HelpCircle, label: "Campus Info", path: "/campus" },
        ].map(({ icon: Icon, label, path }) => (
          <Link 
            key={label} 
            to={path}
            className={cn(
              "flex items-center gap-2 w-full px-3 py-2 rounded-lg text-sm transition-colors",
              location.pathname === path 
                ? "bg-sidebar-accent text-sidebar-accent-foreground" 
                : "text-sidebar-foreground/70 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
            )}
          >
            <Icon className="w-4 h-4" />
            {label}
          </Link>
        ))}
      </nav>

      {/* History */}
      <div className="flex-1 overflow-y-auto px-3 py-2">
        <p className="text-[11px] font-semibold uppercase tracking-wider text-sidebar-foreground/40 px-3 mb-2">
          History
        </p>
        <div className="space-y-0.5">
          {chatHistory.map((chat) => (
            <button
              key={chat.id}
              onClick={() => onSelectChat(chat.id)}
              className={cn(
                "flex flex-col w-full px-3 py-2 rounded-lg text-left transition-colors",
                activeChatId === chat.id
                  ? "bg-sidebar-accent text-sidebar-accent-foreground"
                  : "text-sidebar-foreground/70 hover:bg-sidebar-accent/50"
              )}
            >
              <span className="text-sm font-medium truncate">{chat.title}</span>
              <span className="text-[11px] truncate opacity-60">{chat.preview}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Footer */}
      <div className="px-3 py-3 border-t border-sidebar-border">
        <button className="flex items-center gap-2 w-full px-3 py-2 rounded-lg text-sm text-sidebar-foreground/70 hover:bg-sidebar-accent transition-colors">
          <Settings className="w-4 h-4" />
          Settings
        </button>
      </div>
    </aside>
  );
};

export default ChatSidebar;

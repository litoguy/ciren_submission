import { useState, useCallback } from "react";
import { Menu } from "lucide-react";
import ChatSidebar from "@/components/ChatSidebar";
import ChatWelcome from "@/components/ChatWelcome";
import ChatMessages, { Message } from "@/components/ChatMessages";
import ChatInput from "@/components/ChatInput";
import { api } from "@/lib/api";
import AuthPrompt from "@/components/AuthPrompt";

interface Chat {
  id: string;
  title: string;
  preview: string;
  messages: Message[];
}

const Index = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [chats, setChats] = useState<Chat[]>([]);
  const [activeChatId, setActiveChatId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [pendingSuggestion, setPendingSuggestion] = useState("");

  const activeChat = chats.find((c) => c.id === activeChatId);

  const createChat = useCallback((firstMessage?: string) => {
    const id = crypto.randomUUID();
    const newChat: Chat = {
      id,
      title: firstMessage?.slice(0, 40) || "New Chat",
      preview: firstMessage?.slice(0, 60) || "",
      messages: [],
    };
    setChats((prev) => [newChat, ...prev]);
    setActiveChatId(id);
    return id;
  }, []);

  const handleSend = useCallback(
    async (text: string) => {
      let chatId = activeChatId;
      if (!chatId) {
        chatId = createChat(text);
      }

      const userMsg: Message = { id: crypto.randomUUID(), role: "user", content: text };

      setChats((prev) =>
        prev.map((c) =>
          c.id === chatId
            ? {
                ...c,
                title: c.messages.length === 0 ? text.slice(0, 40) : c.title,
                preview: text.slice(0, 60),
                messages: [...c.messages, userMsg],
              }
            : c
        )
      );

      setIsLoading(true);

      try {
        const response = await api.postChat(text);
        
        if (response.success && response.data) {
          const assistantMsg: Message = {
            id: crypto.randomUUID(),
            role: "assistant",
            content: response.data.reply,
          };

          setChats((prev) =>
            prev.map((c) =>
              c.id === chatId ? { ...c, messages: [...c.messages, assistantMsg] } : c
            )
          );
        }
      } catch (error) {
        console.error("Chat error:", error);
        // Add an error message to the chat
        const errorMsg: Message = {
          id: crypto.randomUUID(),
          role: "assistant",
          content: "Sorry, I encountered an error. Please try again later.",
        };
        setChats((prev) =>
          prev.map((c) =>
            c.id === chatId ? { ...c, messages: [...c.messages, errorMsg] } : c
          )
        );
      } finally {
        setIsLoading(false);
      }
    },
    [activeChatId, createChat]
  );

  const handleSuggestionClick = (prompt: string) => {
    setPendingSuggestion(prompt);
  };

  const handleNewChat = () => {
    setActiveChatId(null);
    setPendingSuggestion("");
  };

  return (
    <div className="flex h-screen bg-background overflow-hidden">
      <ChatSidebar
        chatHistory={chats.map((c) => ({ id: c.id, title: c.title, preview: c.preview }))}
        activeChatId={activeChatId}
        onNewChat={handleNewChat}
        onSelectChat={setActiveChatId}
        isOpen={sidebarOpen}
      />

      <div className="flex-1 flex flex-col min-w-0">
        {/* Header */}
        <header className="flex items-center gap-3 px-4 py-3 border-b border-border bg-card/50 backdrop-blur-sm">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-muted transition-colors text-muted-foreground"
          >
            <Menu className="w-5 h-5" />
          </button>
          <h2 className="font-semibold text-foreground">AI Chat</h2>
          <div className="ml-auto flex items-center gap-2">
            <span className="text-xs px-2.5 py-1 rounded-full bg-gold-pale text-primary font-medium">
              Central University
            </span>
          </div>
        </header>

        {/* Chat area */}
        {activeChat && activeChat.messages.length > 0 ? (
          <>
            <ChatMessages messages={activeChat.messages} isLoading={isLoading} />
            <ChatInput
              onSend={handleSend}
              isLoading={isLoading}
              initialValue={pendingSuggestion}
            />
          </>
        ) : (
          <ChatWelcome onSend={handleSend} isLoading={isLoading} />
        )}
        <AuthPrompt />
      </div>
    </div>
  );
};

export default Index;

import { BookOpen, MapPin, Calendar, HelpCircle, GraduationCap, DollarSign, MessageSquarePlus } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import ChatInput from "./ChatInput";

interface ChatWelcomeProps {
  onSend: (text: string) => void;
  isLoading: boolean;
}

const iconMap: Record<string, any> = {
  fees: DollarSign,
  exams: Calendar,
  academics: BookOpen,
  campus: MapPin,
  help: HelpCircle,
};

const colorMap: Record<string, string> = {
  fees: "bg-gold-pale text-primary",
  exams: "bg-accent text-accent-foreground",
  academics: "bg-secondary text-secondary-foreground",
  campus: "bg-gold-pale text-primary-light",
  help: "bg-accent text-accent-foreground",
};

const ChatWelcome = ({ onSend, isLoading }: ChatWelcomeProps) => {
  const { data: topicsData, isLoading: topicsLoading } = useQuery({
    queryKey: ["topics"],
    queryFn: () => api.getTopics(),
  });

  const { data: faqsData, isLoading: faqsLoading } = useQuery({
    queryKey: ["faqs"],
    queryFn: () => api.getFAQs(),
  });

  const topics = topicsData?.data?.topics || [];
  const faqs = faqsData?.data?.faqs || [];

  return (
    <div className="flex-1 overflow-y-auto w-full">
      <div className="flex flex-col items-center p-6 max-w-4xl mx-auto py-12 space-y-12 min-h-full">
        <div className="flex flex-col items-center text-center space-y-4">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center bg-primary/10 mb-2">
            <GraduationCap className="w-10 h-10 text-primary" />
          </div>
          <h2 className="text-3xl md:text-5xl font-bold text-foreground">
            How can I help you today?
          </h2>
          <p className="text-muted-foreground max-w-md">
            Ask anything about Central University courses, fees, or campus life.
          </p>
        </div>

        <div className="w-full max-w-2xl">
          <ChatInput onSend={onSend} isLoading={isLoading} />
        </div>

        <div className="w-full max-w-3xl space-y-10">
          <div>
            <h3 className="text-sm font-semibold text-foreground/50 mb-4 px-1 uppercase tracking-widest text-center">
              Suggested Topics
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {topicsLoading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <div key={i} className="h-24 rounded-xl bg-card animate-pulse border border-border" />
                ))
              ) : (
                topics.map((topic) => {
                  const Icon = iconMap[topic.id] || HelpCircle;
                  const color = colorMap[topic.id] || "bg-muted text-muted-foreground";
                  
                  return (
                    <button
                      key={topic.id}
                      onClick={() => onSend(topic.prompt)}
                      className="flex flex-col items-center gap-3 p-4 rounded-xl border-[0.5px] border-border bg-card hover:shadow-md hover:border-primary/30 transition-all text-center group"
                    >
                      <div className={`w-10 h-10 rounded-lg ${color} flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform`}>
                        <Icon className="w-5 h-5" />
                      </div>
                      <span className="text-xs font-medium text-foreground line-clamp-1">{topic.label}</span>
                    </button>
                  );
                })
              )}
            </div>
          </div>

          <div className="mt-8 pb-10">
            <h3 className="text-sm font-semibold text-foreground/50 mb-4 px-1 uppercase tracking-widest text-center">
              Common Questions
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {faqsLoading ? (
                Array.from({ length: 2 }).map((_, i) => (
                  <div key={i} className="h-14 rounded-xl bg-card animate-pulse border border-border" />
                ))
              ) : (
                faqs.map((faq) => (
                  <button
                    key={faq.id}
                    onClick={() => onSend(faq.question)}
                    className="flex items-center gap-3 px-4 py-3 rounded-xl border-[0.5px] border-border bg-card hover:shadow-sm hover:border-primary/20 transition-all text-left text-sm text-foreground/80 hover:text-foreground"
                  >
                    <MessageSquarePlus className="w-4 h-4 text-muted-foreground shrink-0" />
                    <span className="line-clamp-1">{faq.question}</span>
                  </button>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChatWelcome;

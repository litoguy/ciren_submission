import { useState, useEffect } from "react";
import { BookOpen, GraduationCap, FileText, Calendar, Book, Users, ClipboardCheck, ArrowLeft, Menu } from "lucide-react";
import { Link } from "react-router-dom";
import ChatSidebar from "@/components/ChatSidebar";
import { api } from "@/lib/api";

const AcademicHelp = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    if (window.innerWidth < 768) setSidebarOpen(false);
  }, []);

  const resources = [
    {
      title: "Course Materials",
      icon: Book,
      description: "Access slides, notes, and prescribed textbooks for your registered courses.",
      color: "bg-gold-pale text-primary",
    },
    {
      title: "GPA Calculator",
      icon: ClipboardCheck,
      description: "Calculate your semester and cumulative GPA based on your grades.",
      color: "bg-accent text-accent-foreground",
    },
    {
      title: "Exam Timetables",
      icon: Calendar,
      description: "Check the latest examination schedules and venue assignments.",
      color: "bg-secondary text-secondary-foreground",
    },
    {
      title: "Study Groups",
      icon: Users,
      description: "Find or create peer study groups for collaborative learning.",
      color: "bg-primary/10 text-primary",
    },
    {
      title: "Past Questions",
      icon: FileText,
      description: "Browse academic archives for past examination papers and solutions.",
      color: "bg-gold-pale text-primary-light",
    },
    {
      title: "Advising",
      icon: GraduationCap,
      description: "Book sessions with academic advisors for course selection guidance.",
      color: "bg-accent text-accent-foreground",
    },
  ];

  return (
    <div className="flex h-screen bg-background overflow-hidden font-sans">
      <ChatSidebar
        chatHistory={[]}
        activeChatId={null}
        onNewChat={() => {}}
        onSelectChat={() => {}}
        isOpen={sidebarOpen}
      />

      <div className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        <header className="flex items-center gap-3 px-4 py-3 border-b border-border bg-card/50 backdrop-blur-sm sticky top-0 z-10">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-muted transition-colors text-muted-foreground mr-2"
          >
            <Menu className="w-5 h-5" />
          </button>
          <Link to="/" className="flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors mr-2">
            <ArrowLeft className="w-4 h-4" />
            <span className="text-sm font-medium">Chat</span>
          </Link>
          <div className="h-4 w-px bg-border mx-2" />
          <div className="flex items-center gap-2">
            <BookOpen className="w-5 h-5 text-primary" />
            <h1 className="font-semibold text-foreground">Academic Help</h1>
          </div>
        </header>

        <main className="flex-1 max-w-4xl w-full mx-auto p-6 md:p-10 space-y-12">
          <section className="space-y-4">
            <h2 className="text-3xl md:text-4xl font-bold tracking-tight text-foreground">
              Everything you need for academic success.
            </h2>
            <p className="text-muted-foreground text-lg max-w-2xl">
              Access resources, schedules, and tools designed to help you excel in your studies at Central University.
            </p>
          </section>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {resources.map((res) => (
              <div 
                key={res.title} 
                className="group p-6 rounded-2xl border-[0.5px] border-border bg-card hover:shadow-lg hover:border-primary/20 transition-all cursor-pointer"
              >
                <div className={`w-12 h-12 rounded-xl ${res.color} flex items-center justify-center mb-5 group-hover:scale-110 transition-transform`}>
                  <res.icon className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-foreground mb-2">{res.title}</h3>
                <p className="text-sm text-muted-foreground leading-relaxed">
                  {res.description}
                </p>
              </div>
            ))}
          </div>

          <section className="p-8 rounded-3xl bg-primary text-primary-foreground relative overflow-hidden">
            <div className="relative z-10 space-y-4 max-w-lg">
              <h3 className="text-2xl font-bold">Need direct assistance?</h3>
              <p className="opacity-90">
                Our AI-powered chat is always available to answer specific questions about your courses or university policies.
              </p>
              <Link to="/">
                <button className="mt-4 px-6 py-3 rounded-xl bg-white text-primary font-bold hover:bg-gold-pale transition-colors shadow-lg shadow-black/small">
                  Ask CU Chat
                </button>
              </Link>
            </div>
            <BookOpen className="absolute -right-8 -bottom-8 w-48 h-48 opacity-10 rotate-12" />
          </section>
        </main>
      </div>
    </div>
  );
};

export default AcademicHelp;

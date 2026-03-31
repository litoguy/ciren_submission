import { useState, useEffect } from "react";
import { HelpCircle, MapPin, Building2, Utensils, Wifi, CreditCard, Ambulance, ArrowLeft, Menu } from "lucide-react";
import { Link } from "react-router-dom";
import ChatSidebar from "@/components/ChatSidebar";
import { api } from "@/lib/api";

const CampusInfo = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    if (window.innerWidth < 768) setSidebarOpen(false);
  }, []);

  const sections = [
    {
      title: "Hostels & Housing",
      icon: Building2,
      description: "Information about on-campus accommodation, rules, and application status.",
      color: "bg-gold-pale text-primary",
    },
    {
      title: "Food & Canteens",
      icon: Utensils,
      description: "Dining options across campus, opening hours, and menu highlights.",
      color: "bg-accent text-accent-foreground",
    },
    {
      title: "Campus Map",
      icon: MapPin,
      description: "Interactive floor plans and campus-wide navigation for easy wayfinding.",
      color: "bg-secondary text-secondary-foreground",
    },
    {
      title: "Connectivity (Wi-Fi)",
      icon: Wifi,
      description: "Troubleshooting campus internet and how to register your devices.",
      color: "bg-primary/10 text-primary",
    },
    {
      title: "Payment Centers",
      icon: CreditCard,
      description: "Locations of banks, ATMs, and university finance offices.",
      color: "bg-gold-pale text-primary-light",
    },
    {
      title: "Health & Safety",
      icon: Ambulance,
      description: "Emergency contacts, campus clinic locations, and safety protocols.",
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
            <HelpCircle className="w-5 h-5 text-primary" />
            <h1 className="font-semibold text-foreground">Campus Info</h1>
          </div>
        </header>

        <main className="flex-1 max-w-4xl w-full mx-auto p-6 md:p-10 space-y-12">
          <section className="space-y-4">
            <h2 className="text-3xl md:text-4xl font-bold tracking-tight text-foreground">
              Explore your campus at Central University.
            </h2>
            <p className="text-muted-foreground text-lg max-w-2xl">
              From hostels to healthcare, find every essential campus service and amenity with ease.
            </p>
          </section>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {sections.map((sec) => (
              <div 
                key={sec.title} 
                className="group p-6 rounded-2xl border-[0.5px] border-border bg-card hover:shadow-lg hover:border-primary/20 transition-all cursor-pointer"
              >
                <div className={`w-12 h-12 rounded-xl ${sec.color} flex items-center justify-center mb-5 group-hover:scale-110 transition-transform`}>
                  <sec.icon className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-foreground mb-2">{sec.title}</h3>
                <p className="text-sm text-muted-foreground leading-relaxed">
                  {sec.description}
                </p>
              </div>
            ))}
          </div>

          <section className="p-10 rounded-3xl bg-secondary text-secondary-foreground relative overflow-hidden text-center">
            <div className="relative z-10 space-y-6 max-w-xl mx-auto">
              <h3 className="text-2xl font-bold">Lost on campus?</h3>
              <p className="opacity-90">
                Ask our AI assistant for specific directions to faculties, lecture halls, or administrative buildings.
              </p>
              <Link to="/" className="inline-block">
                <button className="px-8 py-4 rounded-2xl bg-white text-secondary font-bold hover:bg-gold-pale transition-colors shadow-xl">
                  Try CU Chat Now
                </button>
              </Link>
            </div>
            <MapPin className="absolute -left-12 -top-12 w-64 h-64 opacity-5 rotate-45" />
          </section>
        </main>
      </div>
    </div>
  );
};

export default CampusInfo;

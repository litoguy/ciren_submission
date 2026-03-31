import { useState, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { GraduationCap, LogIn, UserPlus } from "lucide-react";

const AuthPrompt = () => {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const hasSeenAuthPrompt = localStorage.getItem("hasSeenAuthPrompt");
    const isAuthenticated = !!localStorage.getItem("accessToken");
    
    if (!hasSeenAuthPrompt && !isAuthenticated) {
      // Small delay on first load for better UX
      const timer = setTimeout(() => setOpen(true), 1000);
      return () => clearTimeout(timer);
    }
  }, []);

  const handleContinue = () => {
    localStorage.setItem("hasSeenAuthPrompt", "true");
    setOpen(false);
  };

  const handleSignIn = () => {
    localStorage.setItem("hasSeenAuthPrompt", "true");
    setOpen(false);
    // Future: Redirect to login page
    console.log("Redirecting to login...");
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="sm:max-w-md border-none bg-card p-6 gap-6 shadow-2xl">
        <DialogHeader className="items-center text-center gap-4">
          <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center">
            <GraduationCap className="w-10 h-10 text-primary" />
          </div>
          <div>
            <DialogTitle className="text-2xl font-bold text-foreground">
              Welcome to CampusAI
            </DialogTitle>
            <DialogDescription className="text-muted-foreground mt-2">
              Sign in to save your chat history and sync across devices, or continue as a guest.
            </DialogDescription>
          </div>
        </DialogHeader>

        <div className="flex flex-col gap-3">
          <Button 
            onClick={handleSignIn} 
            className="w-full h-12 bg-primary hover:bg-primary-dark text-primary-foreground font-semibold rounded-xl transition-all"
          >
            <LogIn className="mr-2 h-4 w-4" />
            Sign In to your account
          </Button>
          
          <div className="relative flex items-center py-2">
            <div className="flex-grow border-t border-border"></div>
            <span className="flex-shrink mx-4 text-[11px] text-muted-foreground uppercase tracking-widest font-semibold">
              OR
            </span>
            <div className="flex-grow border-t border-border"></div>
          </div>

          <Button 
            variant="outline" 
            onClick={handleContinue} 
            className="w-full h-12 border-border hover:bg-muted text-foreground/80 hover:text-foreground font-medium rounded-xl transition-all"
          >
            Continue as Guest
          </Button>
        </div>

        <DialogFooter className="sm:justify-center">
          <p className="text-[11px] text-muted-foreground text-center">
            By continuing, you agree to our Terms of Service and Privacy Policy.
          </p>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export default AuthPrompt;

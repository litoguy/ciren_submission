import { useState, useRef, useEffect } from "react";
import { Mic, Send, Square, Paperclip } from "lucide-react";

interface ChatInputProps {
  onSend: (message: string) => void;
  isLoading: boolean;
  initialValue?: string;
}

const ChatInput = ({ onSend, isLoading, initialValue = "" }: ChatInputProps) => {
  const [value, setValue] = useState(initialValue);
  const [isListening, setIsListening] = useState(false);
  const [micLevel, setMicLevel] = useState(0);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const recognitionRef = useRef<SpeechRecognition | null>(null);
  const transcriptRef = useRef("");
  const mediaStreamRef = useRef<MediaStream | null>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const rafRef = useRef<number | null>(null);

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

  const speechSupported =
    typeof window !== "undefined" &&
    ("SpeechRecognition" in window || "webkitSpeechRecognition" in window);

  const cleanupAudioMeter = () => {
    if (rafRef.current != null) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }
    analyserRef.current = null;
    if (audioContextRef.current) {
      audioContextRef.current.close().catch(() => {});
      audioContextRef.current = null;
    }
    if (mediaStreamRef.current) {
      mediaStreamRef.current.getTracks().forEach((t) => t.stop());
      mediaStreamRef.current = null;
    }
    setMicLevel(0);
  };

  const stopListening = () => {
    recognitionRef.current?.stop();
    cleanupAudioMeter();
  };

  const startListening = async () => {
    if (isLoading || isListening || !speechSupported) return;

    // Ask for mic permission up front so the user sees the prompt immediately.
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });
      mediaStreamRef.current = stream;

      const AudioContextCtor =
        (window as any).AudioContext || (window as any).webkitAudioContext;
      if (AudioContextCtor) {
        const audioContext: AudioContext = new AudioContextCtor();
        audioContextRef.current = audioContext;

        const source = audioContext.createMediaStreamSource(stream);
        const analyser = audioContext.createAnalyser();
        analyser.fftSize = 1024;
        analyser.smoothingTimeConstant = 0.85;
        source.connect(analyser);
        analyserRef.current = analyser;

        const data = new Uint8Array(analyser.frequencyBinCount);
        const tick = () => {
          const a = analyserRef.current;
          if (!a) return;
          a.getByteTimeDomainData(data);

          // Normalize RMS to 0..1 for a stable UI ring.
          let sumSq = 0;
          for (let i = 0; i < data.length; i++) {
            const v = (data[i] - 128) / 128;
            sumSq += v * v;
          }
          const rms = Math.sqrt(sumSq / data.length); // ~0..1
          const level = Math.min(1, Math.max(0, (rms - 0.02) / 0.25));
          setMicLevel(level);

          rafRef.current = requestAnimationFrame(tick);
        };
        rafRef.current = requestAnimationFrame(tick);
      }
    } catch {
      return;
    }

    const RecognitionCtor =
      (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;

    const recognition: SpeechRecognition = new RecognitionCtor();
    recognitionRef.current = recognition;
    transcriptRef.current = "";

    recognition.continuous = false;
    recognition.interimResults = false;
    recognition.lang = "en-US";

    recognition.onstart = () => {
      setIsListening(true);
    };

    recognition.onresult = (event) => {
      const text = Array.from(event.results)
        .map((r) => r[0]?.transcript ?? "")
        .join(" ")
        .trim();

      transcriptRef.current = text;
      if (text) setValue(text);
    };

    recognition.onerror = () => {
      setIsListening(false);
      cleanupAudioMeter();
    };

    recognition.onend = () => {
      setIsListening(false);
      cleanupAudioMeter();
      const finalText = transcriptRef.current.trim();
      if (!finalText || isLoading) return;
      onSend(finalText);
      setValue("");
      transcriptRef.current = "";
    };

    recognition.start();
  };

  useEffect(() => {
    return () => {
      cleanupAudioMeter();
      recognitionRef.current?.stop();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
            <div className="relative">
              {isListening && (
                <>
                  <div
                    className="pointer-events-none absolute -inset-2 rounded-xl bg-primary/15 blur-[1px] transition-transform"
                    style={{
                      transform: `scale(${1 + micLevel * 0.85})`,
                      opacity: 0.25 + micLevel * 0.55,
                    }}
                  />
                  <div
                    className="pointer-events-none absolute -inset-4 rounded-2xl border border-primary/30 transition-transform"
                    style={{
                      transform: `scale(${1 + micLevel * 1.2})`,
                      opacity: 0.15 + micLevel * 0.35,
                    }}
                  />
                </>
              )}
              <button
                onClick={isListening ? stopListening : startListening}
                disabled={isLoading || !speechSupported}
                title={
                  !speechSupported
                    ? "Voice input not supported in this browser"
                    : isListening
                      ? "Stop voice input"
                      : "Speak (voice input)"
                }
                className={`relative z-10 w-8 h-8 rounded-lg flex items-center justify-center disabled:opacity-40 disabled:cursor-not-allowed transition-colors ${
                  isListening
                    ? "bg-primary text-primary-foreground hover:bg-primary/90"
                    : "bg-muted text-foreground hover:bg-muted/80"
                }`}
              >
                {isListening ? <Square className="w-4 h-4" /> : <Mic className="w-4 h-4" />}
              </button>
            </div>
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

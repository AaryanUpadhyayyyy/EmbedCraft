import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Mail, Lock, Loader2, FileText, ChevronRight, ShieldCheck, Sun, Moon, Shield, File, LockKeyhole, Search } from 'lucide-react';
import { useAuth } from '@/context/AuthContext';

const TypewriterText = ({ text, className, delay = 0 }: { text: string, className?: string, delay?: number }) => {
    return (
        <motion.p
            className={className}
            initial="hidden"
            animate="visible"
            variants={{
                hidden: { opacity: 0 },
                visible: {
                    opacity: 1,
                    transition: {
                        staggerChildren: 0.03,
                        delayChildren: delay
                    }
                }
            }}
        >
            {text.split("").map((char, index) => (
                <motion.span
                    key={`${char}-${index}`}
                    variants={{
                        hidden: { opacity: 0 },
                        visible: { opacity: 1 }
                    }}
                >
                    {char}
                </motion.span>
            ))}
        </motion.p>
    );
};

const BackgroundElement = ({ children, initialX, initialY, duration = 20, delay = 0 }: { children: React.ReactNode, initialX: string, initialY: string, duration?: number, delay?: number }) => (
    <motion.div
        initial={{ x: initialX, y: initialY, opacity: 0, scale: 0.8 }}
        animate={{ 
            y: [initialY, "calc(" + initialY + " - 20px)", initialY],
            opacity: [0.25, 0.5, 0.25],
            rotate: [0, 5, -5, 0]
        }}
        transition={{ 
            duration, 
            repeat: Infinity, 
            delay,
            ease: "easeInOut"
        }}
        className="absolute pointer-events-none z-0"
    >
        {children}
    </motion.div>
);

const Login: React.FC = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const [isDark, setIsDark] = useState(() => 
        typeof window !== "undefined" && document.documentElement.classList.contains("dark")
    );

    useEffect(() => {
        document.documentElement.classList.toggle("dark", isDark);
    }, [isDark]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setIsLoading(true);

        try {
            // Switch between local and production backend based on environment
            const apiUrl = import.meta.env.VITE_API_URL || 
                          (import.meta.env.PROD ? 'https://embed-backend-w9j0.onrender.com' : 'http://localhost:4000');
            
            const response = await fetch(`${apiUrl}/api/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.error || 'Access denied');
            }

            login(data.token, data.user);
            navigate('/');
        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen w-full bg-background flex items-center justify-center p-4 selection:bg-primary selection:text-primary-foreground font-sans overflow-hidden relative">
            {/* Global Scroll Hide */}
            <style>{`
                html, body { 
                    overflow: hidden !important; 
                    height: 100% !important;
                    width: 100% !important;
                    margin: 0 !important;
                    padding: 0 !important;
                    position: fixed !important;
                }
                ::-webkit-scrollbar { display: none !important; }
                * { -ms-overflow-style: none !important; scrollbar-width: none !important; }
            `}</style>

            {/* Subtle Paper Texture Overlay */}
            <div className="fixed inset-0 pointer-events-none opacity-[0.15] mix-blend-multiply bg-[url('https://www.transparenttextures.com/patterns/paper-fibers.png')] z-[5]" />
            
            {/* Document Lines Background */}
            <div className="fixed inset-0 pointer-events-none opacity-[0.12] z-0" 
                 style={{ backgroundImage: 'linear-gradient(hsl(var(--foreground)) 1px, transparent 1px)', backgroundSize: '100% 2.5rem' }} />

            {/* Enhanced Background Design - Floating Documents & Security */}
            <BackgroundElement initialX="5vw" initialY="10vh" duration={25}>
                <File className="w-80 h-80 text-foreground" strokeWidth={0.5} />
            </BackgroundElement>
            <BackgroundElement initialX="80vw" initialY="5vh" duration={30} delay={2}>
                <Shield className="w-64 h-64 text-foreground" strokeWidth={0.5} />
            </BackgroundElement>
            <BackgroundElement initialX="85vw" initialY="65vh" duration={22} delay={1}>
                <FileText className="w-72 h-72 text-foreground" strokeWidth={0.5} />
            </BackgroundElement>
            <BackgroundElement initialX="2vw" initialY="75vh" duration={28} delay={3}>
                <LockKeyhole className="w-56 h-56 text-foreground" strokeWidth={0.5} />
            </BackgroundElement>

            {/* Floating Protocol Text */}
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none select-none z-0 opacity-40">
                <motion.span 
                    animate={{ opacity: [0.4, 0.6, 0.4] }}
                    transition={{ duration: 8, repeat: Infinity }}
                    className="text-[25vw] font-black tracking-tighter text-foreground font-mono leading-[0.8]"
                >
                    DOC
                </motion.span>
                <motion.span 
                    animate={{ opacity: [0.2, 0.4, 0.2] }}
                    transition={{ duration: 10, repeat: Infinity, delay: 1 }}
                    className="text-[15vw] font-black tracking-tighter text-foreground font-mono leading-[0.8]"
                >
                    SECURE
                </motion.span>
            </div>

            {/* Theme Toggle */}
            <div className="fixed top-8 right-8 z-50">
                <button
                    onClick={() => setIsDark(!isDark)}
                    className="p-3 rounded-full border border-border bg-background hover:bg-muted transition-all duration-300 group shadow-lg"
                    title={isDark ? "Switch to Light Mode" : "Switch to Dark Mode"}
                >
                    {isDark ? (
                        <Sun className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                    ) : (
                        <Moon className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                    )}
                </button>
            </div>

            {/* Stacked Paper Effect Behind Card */}
            <div className="relative group">
                <motion.div 
                    initial={{ opacity: 0, rotate: -2 }}
                    animate={{ opacity: 1, rotate: -1 }}
                    className="absolute inset-0 bg-background border border-border-strong translate-x-3 translate-y-3 -z-10"
                />
                <motion.div 
                    initial={{ opacity: 0, rotate: 2 }}
                    animate={{ opacity: 1, rotate: 1 }}
                    className="absolute inset-0 bg-background border border-border-strong translate-x-6 translate-y-6 -z-20 opacity-50"
                />

                <motion.div 
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.8, ease: "circOut" }}
                    className="w-full max-w-[440px] bg-background border border-border-strong p-8 md:p-12 relative z-10 shadow-[0_0_100px_rgba(0,0,0,0.12)]"
                >
                    {/* Decorative Document Elements */}
                    <div className="absolute top-0 left-0 w-full h-1.5 bg-primary" />
                    <div className="absolute top-4 right-4 text-[10px] font-mono text-muted-foreground uppercase tracking-[0.2em]">
                        Document / ID-7742
                    </div>

                    <div className="mb-12">
                        <div className="flex items-center gap-2 mb-6">
                            <FileText className="w-5 h-5 text-primary" />
                            <span className="font-mono text-[10px] uppercase tracking-widest text-muted-foreground">Classified Documentation</span>
                        </div>
                        
                        <h1 className="text-4xl font-bold tracking-tighter mb-4 text-foreground">
                            Access Control
                        </h1>
                        <TypewriterText 
                            text="Restricted Access Area. Authenticate your profile to proceed to the internal documentation repository."
                            className="text-sm text-muted-foreground leading-relaxed font-light"
                            delay={0.5}
                        />
                    </div>

                    {error && (
                        <motion.div
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="mb-8 p-4 bg-muted border-l-2 border-primary text-xs font-mono flex items-start gap-3"
                        >
                            <ShieldCheck className="w-4 h-4 shrink-0 mt-0.5 text-primary" />
                            <div>
                                <p className="font-bold uppercase mb-1 text-primary tracking-wider text-[10px]">AUTH_ERROR</p>
                                <p>{error}</p>
                            </div>
                        </motion.div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-8">
                        <div className="space-y-6">
                            <div className="group relative">
                                <label className="block text-[10px] font-mono uppercase tracking-widest text-muted-foreground mb-2 group-focus-within:text-primary transition-colors">
                                    Email Identifier
                                </label>
                                <div className="relative">
                                    <Mail className="absolute left-0 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                                    <input
                                        type="email"
                                        required
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        className="w-full bg-transparent border-b border-border py-2 pl-7 text-sm focus:outline-none focus:border-primary transition-all placeholder:text-muted-foreground/30"
                                        placeholder="user@embedcraft.com"
                                    />
                                </div>
                            </div>

                            <div className="group relative">
                                <label className="block text-[10px] font-mono uppercase tracking-widest text-muted-foreground mb-2 group-focus-within:text-primary transition-colors">
                                    Security Key
                                </label>
                                <div className="relative">
                                    <Lock className="absolute left-0 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                                    <input
                                        type="password"
                                        required
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        className="w-full bg-transparent border-b border-border py-2 pl-7 text-sm focus:outline-none focus:border-primary transition-all placeholder:text-muted-foreground/30"
                                        placeholder="••••••••"
                                    />
                                </div>
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={isLoading}
                            className="w-full group relative flex items-center justify-between py-4 border border-primary bg-primary text-primary-foreground hover:bg-background hover:text-primary transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed px-6"
                        >
                            <span className="text-xs font-bold uppercase tracking-[0.2em]">
                                {isLoading ? 'Verifying...' : 'Authorize Access'}
                            </span>
                            {isLoading ? (
                                <Loader2 className="w-4 h-4 animate-spin" />
                            ) : (
                                <div className="flex items-center gap-1">
                                    <span className="text-[10px] font-mono opacity-0 group-hover:opacity-100 transition-opacity translate-x-2 group-hover:translate-x-0">EXE</span>
                                    <ChevronRight className="w-4 h-4" />
                                </div>
                            )}
                        </button>
                    </form>

                    <div className="mt-12 pt-8 border-t border-border/50 flex items-center justify-between">
                        <div className="text-[9px] font-mono text-muted-foreground uppercase leading-tight">
                            © 2026 EmbedCraft <br /> 
                            Secure Access Protocol
                        </div>
                        <div className="w-8 h-8 rounded-full border border-border flex items-center justify-center opacity-20 relative">
                            <div className="w-4 h-px bg-foreground rotate-45 absolute" />
                            <div className="w-4 h-px bg-foreground -rotate-45 absolute" />
                        </div>
                    </div>
                </motion.div>
            </div>
        </div>
    );
};

export default Login;

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Route, Routes, Navigate, useLocation } from "react-router-dom";
import { Suspense, ReactNode } from "react";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { DocsLayout } from "@/components/docs/DocsLayout";
import { AuthProvider, useAuth } from "./context/AuthContext";
import Index from "./pages/Index.tsx";
import Login from "./pages/Login.tsx";
import NotFound from "./pages/NotFound.tsx";
import { docRoutes } from "./pages/docRoutes";

const queryClient = new QueryClient();

const PageFallback = () => (
  <div className="px-10 py-16 text-sm text-muted-foreground">Loading…</div>
);

const ProtectedRoute = ({ children }: { children: ReactNode }) => {
  const { isAuthenticated, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return <div className="h-screen w-screen flex items-center justify-center bg-background text-foreground font-mono text-xs uppercase tracking-widest">Initialising Secure Session...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

const PublicRoute = ({ children }: { children: ReactNode }) => {
  const { isAuthenticated, isLoading } = useAuth();
  
  if (isLoading) {
    return null;
  }

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }
  return <>{children}</>;
};

const AppRoutes = () => (
  <Routes>
    <Route 
      path="/login" 
      element={
        <PublicRoute>
          <Login />
        </PublicRoute>
      } 
    />
    <Route 
      element={
        <ProtectedRoute>
          <DocsLayout />
        </ProtectedRoute>
      }
    >
      <Route path="/" element={<Index />} />
      {/* One explicit route per doc page — each page is its own .tsx file in src/pages/docs/. */}
      {docRoutes.map(({ slug, component: Component }) => (
        <Route
          key={slug}
          path={slug}
          element={
            <Suspense fallback={<PageFallback />}>
              <Component />
            </Suspense>
          }
        />
      ))}
      {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
      <Route path="*" element={<NotFound />} />
    </Route>
  </Routes>
);

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <AppRoutes />
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;

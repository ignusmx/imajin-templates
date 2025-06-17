<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.name', 'Laravel') }} - Docker Template</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700" rel="stylesheet" />
    
    <!-- Styles -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            color: #334155;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .header {
            padding: 20px 0;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .header .container {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: white;
            text-decoration: none;
        }
        
        .nav {
            display: flex;
            gap: 30px;
        }
        
        .nav a {
            color: white;
            text-decoration: none;
            font-weight: 500;
            transition: opacity 0.3s;
        }
        
        .nav a:hover {
            opacity: 0.8;
        }
        
        .hero {
            padding: 100px 0;
            text-align: center;
            color: white;
        }
        
        .hero h1 {
            font-size: 48px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.2;
        }
        
        .hero p {
            font-size: 20px;
            margin-bottom: 40px;
            opacity: 0.9;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 60px;
        }
        
        .btn {
            padding: 15px 30px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            display: inline-block;
        }
        
        .btn-primary {
            background: white;
            color: #667eea;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .btn-secondary {
            background: transparent;
            color: white;
            border: 2px solid white;
        }
        
        .btn-secondary:hover {
            background: white;
            color: #667eea;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 30px;
            margin-top: 60px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: 700;
            color: white;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: rgba(255, 255, 255, 0.8);
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .features {
            background: white;
            padding: 100px 0;
        }
        
        .features h2 {
            text-align: center;
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #1e293b;
        }
        
        .features-subtitle {
            text-align: center;
            font-size: 18px;
            color: #64748b;
            margin-bottom: 60px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 40px;
        }
        
        .feature-card {
            text-align: center;
            padding: 40px 20px;
            border-radius: 12px;
            transition: transform 0.3s;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
        }
        
        .feature-icon {
            font-size: 48px;
            margin-bottom: 20px;
        }
        
        .feature-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #1e293b;
        }
        
        .feature-description {
            color: #64748b;
            line-height: 1.6;
        }
        
        .tech-stack {
            background: #f8fafc;
            padding: 80px 0;
        }
        
        .tech-stack h2 {
            text-align: center;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 50px;
            color: #1e293b;
        }
        
        .tech-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 30px;
            text-align: center;
        }
        
        .tech-item {
            background: white;
            padding: 30px 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s;
        }
        
        .tech-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        .tech-item h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
            color: #1e293b;
        }
        
        .tech-version {
            color: #667eea;
            font-weight: 500;
        }
        
        .footer {
            background: #1e293b;
            color: white;
            padding: 40px 0;
            text-align: center;
        }
        
        .footer-links {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .footer-links a {
            color: #94a3b8;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .footer-links a:hover {
            color: white;
        }
        
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(34, 197, 94, 0.1);
            color: #22c55e;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 20px;
        }
        
        .status-dot {
            width: 8px;
            height: 8px;
            background: #22c55e;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        @media (max-width: 768px) {
            .hero h1 {
                font-size: 36px;
            }
            
            .hero p {
                font-size: 18px;
            }
            
            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .nav {
                gap: 20px;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <a href="/" class="logo">🚀 Laravel Docker</a>
            <nav class="nav">
                <a href="/">Home</a>
                <a href="/about">About</a>
                <a href="/dashboard">Dashboard</a>
                <a href="/api/v1/status" target="_blank">API</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="status-badge">
                <span class="status-dot"></span>
                All systems operational
            </div>
            
            <h1>Laravel Docker Template</h1>
            <p>Production-ready Laravel starter with Docker-first development, PostgreSQL, Redis, and modern PHP tooling. Get from zero to deployed in under 2 minutes.</p>
            
            <div class="cta-buttons">
                <a href="/dashboard" class="btn btn-primary">View Dashboard</a>
                <a href="/api/v1/status" class="btn btn-secondary" target="_blank">Test API</a>
            </div>

            <!-- Stats -->
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number">{{ $stats['users'] ?? 0 }}</div>
                    <div class="stat-label">Active Users</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">{{ $stats['projects'] ?? 0 }}</div>
                    <div class="stat-label">Projects</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">{{ $stats['deployments'] ?? 0 }}</div>
                    <div class="stat-label">Deployments</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">{{ $stats['uptime'] ?? '99.9%' }}</div>
                    <div class="stat-label">Uptime</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <h2>Everything You Need</h2>
            <p class="features-subtitle">A complete development environment with modern tools and best practices built-in</p>
            
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">🐳</div>
                    <h3 class="feature-title">Docker-First Development</h3>
                    <p class="feature-description">Complete containerized environment with hot reload, debugging, and production optimization</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">⚡</div>
                    <h3 class="feature-title">Lightning Fast Setup</h3>
                    <p class="feature-description">One command setup with automated scripts. From git clone to running app in under 2 minutes</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🔒</div>
                    <h3 class="feature-title">Production Ready</h3>
                    <p class="feature-description">Security best practices, health checks, monitoring, and deployment configuration included</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🧪</div>
                    <h3 class="feature-title">Comprehensive Testing</h3>
                    <p class="feature-description">PHPUnit, code coverage, security audits, and performance testing pre-configured</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">📊</div>
                    <h3 class="feature-title">Modern Tooling</h3>
                    <p class="feature-description">Vite, Pint, PHPStan, Xdebug, and CI/CD pipeline with GitHub Actions</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🚀</div>
                    <h3 class="feature-title">API Ready</h3>
                    <p class="feature-description">RESTful API endpoints, authentication, validation, and documentation examples</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Tech Stack -->
    <section class="tech-stack">
        <div class="container">
            <h2>Modern Tech Stack</h2>
            
            <div class="tech-grid">
                <div class="tech-item">
                    <h3>Laravel</h3>
                    <div class="tech-version">v11.x</div>
                </div>
                <div class="tech-item">
                    <h3>PHP</h3>
                    <div class="tech-version">v8.3</div>
                </div>
                <div class="tech-item">
                    <h3>PostgreSQL</h3>
                    <div class="tech-version">v16</div>
                </div>
                <div class="tech-item">
                    <h3>Redis</h3>
                    <div class="tech-version">v7</div>
                </div>
                <div class="tech-item">
                    <h3>Docker</h3>
                    <div class="tech-version">Latest</div>
                </div>
                <div class="tech-item">
                    <h3>Vite</h3>
                    <div class="tech-version">v5</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-links">
                <a href="/about">About</a>
                <a href="/api/v1/status" target="_blank">API Status</a>
                <a href="/health" target="_blank">Health Check</a>
                <a href="https://laravel.com/docs" target="_blank">Documentation</a>
                <a href="https://github.com" target="_blank">GitHub</a>
            </div>
            <p>&copy; {{ date('Y') }} Laravel Docker Template. Built with ❤️ for developers.</p>
        </div>
    </footer>

    <script>
        // Simple stats animation
        document.addEventListener('DOMContentLoaded', function() {
            const statNumbers = document.querySelectorAll('.stat-number');
            
            statNumbers.forEach(stat => {
                const targetValue = stat.textContent;
                if (!isNaN(targetValue.replace(/,/g, ''))) {
                    const finalValue = parseInt(targetValue.replace(/,/g, ''));
                    let currentValue = 0;
                    const increment = finalValue / 50;
                    
                    const timer = setInterval(() => {
                        currentValue += increment;
                        if (currentValue >= finalValue) {
                            currentValue = finalValue;
                            clearInterval(timer);
                        }
                        stat.textContent = Math.floor(currentValue).toLocaleString();
                    }, 30);
                }
            });
        });
    </script>
</body>
</html> 
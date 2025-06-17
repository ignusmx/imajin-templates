<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - {{ config('app.name', 'Laravel') }}</title>
    
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
            background: #f8fafc;
        }
        
        .header {
            background: white;
            border-bottom: 1px solid #e2e8f0;
            padding: 20px 0;
        }
        
        .header .container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            text-decoration: none;
        }
        
        .nav {
            display: flex;
            gap: 30px;
        }
        
        .nav a {
            color: #64748b;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
        }
        
        .nav a:hover, .nav a.active {
            color: #667eea;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .dashboard {
            padding: 40px 0;
        }
        
        .page-header {
            margin-bottom: 40px;
        }
        
        .page-title {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
        }
        
        .page-subtitle {
            color: #64748b;
            font-size: 16px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
        }
        
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 16px;
        }
        
        .stat-title {
            font-size: 14px;
            font-weight: 500;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        
        .stat-icon.blue { background: rgba(102, 126, 234, 0.1); color: #667eea; }
        .stat-icon.green { background: rgba(34, 197, 94, 0.1); color: #22c55e; }
        .stat-icon.yellow { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
        .stat-icon.red { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
        
        .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 8px;
        }
        
        .stat-change {
            font-size: 14px;
            font-weight: 500;
        }
        
        .stat-change.positive { color: #22c55e; }
        .stat-change.negative { color: #ef4444; }
        
        .main-content {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }
        
        .activity-section {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
        }
        
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .activity-list {
            list-style: none;
        }
        
        .activity-item {
            padding: 16px 0;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .activity-item:last-child {
            border-bottom: none;
        }
        
        .activity-icon {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .activity-content {
            flex: 1;
        }
        
        .activity-text {
            font-size: 14px;
            color: #334155;
            margin-bottom: 4px;
        }
        
        .activity-time {
            font-size: 12px;
            color: #64748b;
        }
        
        .quick-actions {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
            margin-bottom: 24px;
        }
        
        .action-grid {
            display: grid;
            gap: 12px;
        }
        
        .action-btn {
            padding: 16px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            text-decoration: none;
            color: #334155;
            font-weight: 500;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 12px;
            background: white;
        }
        
        .action-btn:hover {
            border-color: #667eea;
            background: #f8fafc;
            transform: translateY(-1px);
        }
        
        .system-status {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
        }
        
        .status-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-label {
            font-size: 14px;
            color: #334155;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .status-badge.online {
            background: rgba(34, 197, 94, 0.1);
            color: #22c55e;
        }
        
        .status-badge.warning {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }
        
        .api-endpoints {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
            margin-top: 24px;
        }
        
        .endpoint-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px;
            margin: 8px 0;
            background: #f8fafc;
            border-radius: 8px;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 14px;
        }
        
        .endpoint-method {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
            color: white;
        }
        
        .method-get { background: #22c55e; }
        .method-post { background: #3b82f6; }
        .method-put { background: #f59e0b; }
        .method-delete { background: #ef4444; }
        
        @media (max-width: 768px) {
            .main-content {
                grid-template-columns: 1fr;
            }
            
            .nav {
                display: none;
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
                <a href="/dashboard" class="active">Dashboard</a>
                <a href="/api/v1/status" target="_blank">API</a>
            </nav>
        </div>
    </header>

    <!-- Dashboard -->
    <main class="dashboard">
        <div class="container">
            <div class="page-header">
                <h1 class="page-title">Dashboard</h1>
                <p class="page-subtitle">Monitor your Laravel application performance and health</p>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-title">Active Users</div>
                        <div class="stat-icon blue">👥</div>
                    </div>
                    <div class="stat-value">1,247</div>
                    <div class="stat-change positive">↗ +12% from last week</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-title">API Requests</div>
                        <div class="stat-icon green">🔄</div>
                    </div>
                    <div class="stat-value">45,678</div>
                    <div class="stat-change positive">↗ +8% from last week</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-title">Response Time</div>
                        <div class="stat-icon yellow">⚡</div>
                    </div>
                    <div class="stat-value">127ms</div>
                    <div class="stat-change negative">↘ +5ms from last week</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-title">Uptime</div>
                        <div class="stat-icon green">✅</div>
                    </div>
                    <div class="stat-value">99.9%</div>
                    <div class="stat-change positive">✅ All systems operational</div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="main-content">
                <!-- Recent Activity -->
                <div class="activity-section">
                    <h2 class="section-title">
                        📊 Recent Activity
                    </h2>
                    <ul class="activity-list">
                        @if(isset($recentActivity))
                            @foreach($recentActivity as $activity)
                                <li class="activity-item">
                                    <div class="activity-icon">🔔</div>
                                    <div class="activity-content">
                                        <div class="activity-text">{{ $activity }}</div>
                                        <div class="activity-time">{{ now()->subMinutes(rand(5, 60))->diffForHumans() }}</div>
                                    </div>
                                </li>
                            @endforeach
                        @else
                            <li class="activity-item">
                                <div class="activity-icon">🔔</div>
                                <div class="activity-content">
                                    <div class="activity-text">Application started successfully</div>
                                    <div class="activity-time">{{ now()->diffForHumans() }}</div>
                                </div>
                            </li>
                            <li class="activity-item">
                                <div class="activity-icon">🚀</div>
                                <div class="activity-content">
                                    <div class="activity-text">Docker containers are running</div>
                                    <div class="activity-time">{{ now()->subMinutes(5)->diffForHumans() }}</div>
                                </div>
                            </li>
                            <li class="activity-item">
                                <div class="activity-icon">💾</div>
                                <div class="activity-content">
                                    <div class="activity-text">Database connection established</div>
                                    <div class="activity-time">{{ now()->subMinutes(10)->diffForHumans() }}</div>
                                </div>
                            </li>
                        @endif
                    </ul>
                </div>

                <!-- Sidebar -->
                <div>
                    <!-- Quick Actions -->
                    <div class="quick-actions">
                        <h3 class="section-title">⚡ Quick Actions</h3>
                        <div class="action-grid">
                            <a href="/api/v1/status" target="_blank" class="action-btn">
                                📊 API Status
                            </a>
                            <a href="/health" target="_blank" class="action-btn">
                                🏥 Health Check
                            </a>
                            <a href="/phpinfo" target="_blank" class="action-btn">
                                🔧 PHP Info
                            </a>
                            <a href="/config" target="_blank" class="action-btn">
                                ⚙️ Configuration
                            </a>
                        </div>
                    </div>

                    <!-- System Status -->
                    <div class="system-status">
                        <h3 class="section-title">🖥️ System Status</h3>
                        <div class="status-item">
                            <span class="status-label">Laravel Application</span>
                            <span class="status-badge online">Online</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">PostgreSQL Database</span>
                            <span class="status-badge online">Connected</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">Redis Cache</span>
                            <span class="status-badge online">Active</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">Queue Worker</span>
                            <span class="status-badge online">Running</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">Disk Space</span>
                            <span class="status-badge warning">78% Used</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- API Endpoints -->
            <div class="api-endpoints">
                <h3 class="section-title">🌐 Available API Endpoints</h3>
                <div class="endpoint-item">
                    <div>
                        <span class="endpoint-method method-get">GET</span>
                        /api/v1/status
                    </div>
                    <a href="/api/v1/status" target="_blank">→</a>
                </div>
                <div class="endpoint-item">
                    <div>
                        <span class="endpoint-method method-get">GET</span>
                        /api/v1/health
                    </div>
                    <a href="/api/v1/health" target="_blank">→</a>
                </div>
                <div class="endpoint-item">
                    <div>
                        <span class="endpoint-method method-get">GET</span>
                        /api/v1/stats
                    </div>
                    <a href="/api/v1/stats" target="_blank">→</a>
                </div>
                <div class="endpoint-item">
                    <div>
                        <span class="endpoint-method method-get">GET</span>
                        /api/v1/items
                    </div>
                    <a href="/api/v1/items" target="_blank">→</a>
                </div>
                <div class="endpoint-item">
                    <div>
                        <span class="endpoint-method method-post">POST</span>
                        /api/v1/items
                    </div>
                    <span>Create new item</span>
                </div>
            </div>
        </div>
    </main>

    <script>
        // Auto-refresh stats every 30 seconds
        setInterval(() => {
            // In a real app, you'd fetch updated stats here
            console.log('Stats would be refreshed here');
        }, 30000);

        // Add click handlers for quick actions
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                // Add loading state
                this.style.opacity = '0.7';
                setTimeout(() => {
                    this.style.opacity = '1';
                }, 500);
            });
        });
    </script>
</body>
</html> 
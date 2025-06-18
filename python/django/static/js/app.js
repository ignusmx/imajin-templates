// Django Docker Template - JavaScript Application

// Simple utility functions
window.utils = {
    // Format numbers with commas
    formatNumber(num) {
        return new Intl.NumberFormat().format(num);
    },
    
    // Simple notification system
    notify(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Add to page
        document.body.appendChild(notification);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.remove();
        }, 3000);
    },
    
    // API helper with Django CSRF protection
    async api(endpoint, options = {}) {
        try {
            // Get CSRF token
            const csrfToken = document.querySelector('[name=csrfmiddlewaretoken]')?.value || 
                             document.querySelector('meta[name=csrf-token]')?.getAttribute('content');
            
            const headers = {
                'Content-Type': 'application/json',
                ...options.headers
            };
            
            if (csrfToken) {
                headers['X-CSRFToken'] = csrfToken;
            }
            
            const response = await fetch(`/api/v1/${endpoint}`, {
                method: 'GET',
                ...options,
                headers
            });
            
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'API request failed');
            }
            
            return data;
        } catch (error) {
            console.error('API Error:', error);
            this.notify('API request failed', 'error');
            throw error;
        }
    },
    
    // Copy text to clipboard
    async copyToClipboard(text) {
        try {
            await navigator.clipboard.writeText(text);
            this.notify('Copied to clipboard', 'success');
        } catch (err) {
            console.error('Failed to copy: ', err);
            this.notify('Failed to copy', 'error');
        }
    },
    
    // Simple date formatter
    formatDate(date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date(date));
    }
};

// Alpine.js components
document.addEventListener('alpine:init', () => {
    Alpine.data('statsCounter', () => ({
        counts: {},
        
        init() {
            // Animate numbers on page load
            this.animateNumbers();
        },
        
        animateNumbers() {
            const statElements = this.$el.querySelectorAll('[data-count]');
            
            statElements.forEach(element => {
                const targetValue = parseInt(element.dataset.count);
                const duration = 2000; // 2 seconds
                const startTime = Date.now();
                
                const animate = () => {
                    const elapsed = Date.now() - startTime;
                    const progress = Math.min(elapsed / duration, 1);
                    
                    // Easing function
                    const easeOut = 1 - Math.pow(1 - progress, 3);
                    const currentValue = Math.floor(targetValue * easeOut);
                    
                    element.textContent = utils.formatNumber(currentValue);
                    
                    if (progress < 1) {
                        requestAnimationFrame(animate);
                    } else {
                        element.textContent = utils.formatNumber(targetValue);
                    }
                };
                
                animate();
            });
        }
    }));
    
    Alpine.data('apiTester', () => ({
        endpoint: 'status',
        response: null,
        loading: false,
        
        async testEndpoint() {
            this.loading = true;
            this.response = null;
            
            try {
                const data = await utils.api(this.endpoint);
                this.response = JSON.stringify(data, null, 2);
                utils.notify('API request successful', 'success');
            } catch (error) {
                this.response = JSON.stringify({
                    error: error.message
                }, null, 2);
                utils.notify('API request failed', 'error');
            } finally {
                this.loading = false;
            }
        }
    }));
});

// Auto-refresh functionality
function startAutoRefresh(selector, interval = 30000) {
    const elements = document.querySelectorAll(selector);
    
    if (elements.length === 0) return;
    
    setInterval(async () => {
        try {
            const data = await utils.api('stats');
            
            elements.forEach(element => {
                const key = element.dataset.key;
                if (data.data && data.data[key]) {
                    element.textContent = data.data[key];
                }
            });
            
            console.log('Stats refreshed');
        } catch (error) {
            console.error('Failed to refresh stats:', error);
        }
    }, interval);
}

// Initialize auto-refresh on dashboard
if (window.location.pathname.includes('dashboard')) {
    document.addEventListener('DOMContentLoaded', () => {
        startAutoRefresh('[data-auto-refresh]');
    });
}

// Global error handler
window.addEventListener('error', (event) => {
    console.error('Global error:', event.error);
    utils.notify('An unexpected error occurred', 'error');
});

console.log('🚀 Django Docker Template - JavaScript loaded!'); 
import Alpine from 'alpinejs'
import axios from 'axios'

// Make Alpine available globally
window.Alpine = Alpine

// Configure Axios defaults
window.axios = axios
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'

// Add CSRF token if available
const token = document.querySelector('meta[name="csrf-token"]')
if (token) {
    axios.defaults.headers.common['X-CSRF-TOKEN'] = token.getAttribute('content')
}

// Initialize Alpine
Alpine.start()

// Simple utility functions
window.utils = {
    // Format numbers with commas
    formatNumber(num) {
        return new Intl.NumberFormat().format(num)
    },
    
    // Simple notification system
    notify(message, type = 'info') {
        const notification = document.createElement('div')
        notification.className = `notification notification-${type}`
        notification.textContent = message
        
        // Add to page
        document.body.appendChild(notification)
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.remove()
        }, 3000)
    },
    
    // API helper
    async api(endpoint, options = {}) {
        try {
            const response = await axios({
                url: `/api/v1/${endpoint}`,
                method: 'GET',
                ...options
            })
            return response.data
        } catch (error) {
            console.error('API Error:', error)
            this.notify('API request failed', 'error')
            throw error
        }
    }
}

// Add some basic styles for notifications
const style = document.createElement('style')
style.textContent = `
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 16px;
        border-radius: 8px;
        color: white;
        z-index: 1000;
        font-weight: 500;
        animation: slideIn 0.3s ease-out;
    }
    
    .notification-info { background-color: #3b82f6; }
    .notification-success { background-color: #22c55e; }
    .notification-warning { background-color: #f59e0b; }
    .notification-error { background-color: #ef4444; }
    
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
`
document.head.appendChild(style)

console.log('🚀 Laravel Docker Template - JavaScript loaded!') 
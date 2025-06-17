# 🚀 Imajin Project Templates

A curated collection of production-ready starter templates for rapid project development with modern tooling and best practices.

## 📋 Available Templates

### **Backend Frameworks**
- **[Ruby on Rails](./ruby/rails/)** - Full-stack web application with modern tooling
  - Ruby 3.x, Rails 8.x
  - PostgreSQL, Redis ready
  - Tailwind CSS, Stimulus
  - RSpec, Factory Bot
  - Docker support

- **[Ruby/Sinatra](./ruby/sinatra/)** - Lightweight API framework for microservices
  - Ruby 3.x, Sinatra 4.x
  - PostgreSQL, Redis ready
  - JSON API with OpenAPI/Swagger
  - RSpec, Rack::Test
  - Docker support
  - JWT authentication ready

- **[PHP/Laravel](./php/laravel/)** - Modern PHP framework with elegant syntax
  - PHP 8.3, Laravel 11
  - PostgreSQL, Redis ready
  - Vite for modern frontend assets
  - PHPUnit, Pint, PHPStan
  - Docker support with Xdebug

### **Coming Soon**
- **Python/Django** - High-performance web framework with async support
- **JavaScript/Next.js 15** - React-based full-stack framework with App Router
- **Go/Gin** - Lightweight, high-performance web framework
- **Rust/Axum** - Ultra-fast async web framework

## 🛠️ Quick Start

### **Method 1: Direct Copy (Recommended)**

1. **Choose your template** from the available options above
2. **Copy the template directory** to your project location:
   ```bash
   # Example: Using Rails template
   cp -r templates/ruby/rails my-awesome-project
   cd my-awesome-project
   ```
3. **Follow the template-specific setup instructions** in the template's README

### **Method 2: Using degit (Clean Clone)**
```bash
# Install degit globally (if not already installed)
npm install -g degit

# Clone specific template without git history
degit imajin-org/templates/ruby/rails my-awesome-project
cd my-awesome-project
```

### **Method 3: Git Sparse Checkout (Advanced)**
```bash
# Clone only the specific template you need
git clone --filter=blob:none --sparse https://github.com/imajin-org/templates.git temp-clone
cd temp-clone
git sparse-checkout set ruby/rails
cp -r ruby/rails ../my-awesome-project
cd ../my-awesome-project
rm -rf ../temp-clone
```

## 🎯 What Makes These Templates Special

### **Production-Ready from Day One**
- ✅ **Security best practices** built-in
- ✅ **Performance optimizations** pre-configured
- ✅ **Testing frameworks** with example tests
- ✅ **CI/CD pipeline** examples included
- ✅ **Docker support** for development and production
- ✅ **Environment management** with .env examples

### **Developer Experience First**
- ✅ **Modern tooling** (linters, formatters, hot reload)
- ✅ **Comprehensive documentation** 
- ✅ **Clear project structure** with conventions
- ✅ **Pre-commit hooks** for code quality
- ✅ **VS Code settings** optimized for each stack

## 📁 Template Structure Standards

Each template follows consistent conventions:

```
template-name/
├── README.md              # Template-specific setup guide
├── .env.example          # All required environment variables
├── .gitignore            # Framework-specific ignore patterns
├── docker-compose.yml    # Development environment
├── Dockerfile           # Production container
├── package.json         # Dependencies (Node.js projects)
├── Gemfile              # Dependencies (Ruby projects)
├── requirements.txt     # Dependencies (Python projects)
├── .github/
│   └── workflows/       # CI/CD pipeline examples
└── docs/               # Additional documentation
    ├── DEPLOYMENT.md    # Production deployment guide
    ├── DEVELOPMENT.md   # Development environment setup
    └── ARCHITECTURE.md  # Design decisions and patterns
```

## 🚀 Getting Started with a Template

After copying a template, follow these general steps:

1. **Read the template README** - Each template has specific instructions
2. **Copy environment variables**: `cp .env.example .env`
3. **Install dependencies** - Follow template's dependency installation guide
4. **Run setup scripts** - Many templates include setup automation
5. **Start development server** - Usually `npm run dev`, `rails server`, etc.
6. **Run tests** - Ensure everything works: `npm test`, `rspec`, etc.

## 🤝 Contributing New Templates

### **Template Requirements**
All templates must include:

- **Framework/Language**: Latest stable version
- **Documentation**: Comprehensive README with setup instructions
- **Testing**: Pre-configured testing framework with examples
- **Linting**: Code quality tools (ESLint, RuboCop, etc.)
- **Formatting**: Consistent code formatting (Prettier, etc.)
- **Environment**: .env.example with all required variables
- **Docker**: Development and production containerization
- **CI/CD**: GitHub Actions workflow examples
- **Security**: Basic security configurations

### **Adding a New Template**

1. **Create the directory structure**:
   ```bash
   mkdir -p templates/[language]/[framework]
   cd templates/[language]/[framework]
   ```

2. **Follow naming conventions**:
   - Use lowercase with hyphens: `next-js`, `ruby-rails`, `python-django`
   - Group by primary language/ecosystem
   - Keep names concise but descriptive

3. **Include all required files** (see Template Structure above)

4. **Test your template**:
   ```bash
   # Copy to a test directory and verify it works
   cp -r templates/[language]/[framework] test-project
   cd test-project
   # Follow your own setup instructions
   ```

5. **Update this README** with your new template

### **Template Quality Checklist**
- [ ] Follows language/framework best practices
- [ ] Includes comprehensive error handling
- [ ] Has meaningful test coverage (>80%)
- [ ] Includes proper logging configuration
- [ ] Uses environment variables for configuration
- [ ] Includes deployment documentation
- [ ] Follows security best practices
- [ ] Has clear, step-by-step setup instructions

## 📚 Template Documentation Standards

Each template's README should include:

### **Required Sections**
- **🎯 Overview** - What the template provides and use cases
- **📋 Prerequisites** - System requirements and versions
- **⚡ Quick Start** - Get running in under 5 minutes
- **🔧 Development Setup** - Detailed local development instructions
- **📁 Project Structure** - Key files and directories explained
- **🛠️ Available Scripts** - All npm/rake/make commands documented
- **🚀 Deployment** - Production deployment instructions
- **🧪 Testing** - How to run and write tests

### **Optional but Recommended**
- **🏗️ Architecture** - High-level design and patterns used
- **⚡ Performance** - Optimization techniques implemented
- **🐛 Troubleshooting** - Common issues and solutions
- **📝 Changelog** - Template version history
- **🤝 Contributing** - Template-specific contribution guidelines

## 🔧 Template Maintenance

### **Versioning Strategy**
- **Semantic Versioning**: Templates use semver via git tags
- **LTS Branches**: Long-term support for major versions
- **Migration Guides**: For breaking changes between versions

### **Update Schedule**
- **🔒 Security Updates**: Immediate (as needed)
- **🐛 Bug Fixes**: Weekly
- **✨ Feature Updates**: Monthly
- **🎯 Major Versions**: Quarterly

### **Dependency Management**
- Regular dependency audits and updates
- Automated security vulnerability scanning
- Compatibility testing with latest framework versions

## 📞 Support & Community

- **🐛 Bug Reports**: [GitHub Issues](https://github.com/imajin-org/templates/issues)
- **💡 Feature Requests**: [GitHub Discussions](https://github.com/imajin-org/templates/discussions)
- **📖 Documentation**: [Project Wiki](https://github.com/imajin-org/templates/wiki)
- **💬 Community Chat**: [Discord Server](https://discord.gg/imajin)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with ❤️ by the Imajin team and our amazing community contributors.

Special thanks to all the open-source projects that make these templates possible.

---

**Start building amazing projects faster with Imajin Templates! 🚀**

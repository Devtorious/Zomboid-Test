# Contributing to Project Zomboid ARM64 Docker

Thank you for considering contributing to this project! Here's how you can help.

## How to Contribute

### Reporting Issues

If you encounter bugs or have feature requests:

1. Check if the issue already exists
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Your device specifications
   - Docker version
   - Relevant logs

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style
   - Test on ARM64 device if possible
   - Update documentation if needed
4. **Commit your changes**
   ```bash
   git commit -m "Description of changes"
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Create a Pull Request**

### Testing Requirements

Before submitting a PR:

- [ ] Test on actual ARM64 hardware if possible
- [ ] Verify Docker container builds successfully
- [ ] Test server startup and connection
- [ ] Check that existing functionality isn't broken
- [ ] Update README.md if adding new features
- [ ] Update .env.example if adding new variables

### Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing formatting in scripts
- Keep Dockerfile layers optimized

### Areas for Contribution

We welcome contributions in these areas:

- **Performance improvements** - Optimize Box64 settings, reduce memory usage
- **Documentation** - Improve guides, add examples, fix typos
- **Testing** - Test on different ARM64 devices and report results
- **Features** - Add new functionality (RCON support, better logging, etc.)
- **Bug fixes** - Fix issues reported by users
- **CasaOS integration** - Improve CasaOS compatibility

### Development Setup

To work on this project locally:

1. Clone the repository
2. Make your changes
3. Test with:
   ```bash
   docker build -t zomboid-test .
   docker-compose up
   ```

### Questions?

Feel free to open an issue for questions about:
- Project structure
- Implementation details
- Feature feasibility
- Testing approaches

## Code of Conduct

- Be respectful and constructive
- Help others learn
- Credit sources and contributors
- Focus on improving the project

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

Thank you for helping make this project better! 🎮

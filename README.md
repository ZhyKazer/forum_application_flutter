## 1. Application Scope & Feature Checklist

Before writing code, the core application scope and user permissions are defined below. Use this checklist to track feature completion.

### Authentication & Permissions
- [ ] Users can browse posts without logging in
- [ ] Users must be logged in to create, update, delete, or comment
- [ ] Only post owners can update or delete their own posts
- [ ] Only comment owners can update or delete their own comments

### Media & Storage
- [ ] Support for multiple images per post
- [ ] Support for multiple images per comment
- [ ] Image assets securely stored in **Supabase Storage**

### Architecture & Data
- [ ] Post and comment metadata stored in **Supabase Database**
- [ ] Application state managed via **Provider**
- [ ] Navigation and authentication routing handled via **go_router**


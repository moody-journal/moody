# Moody 

[![Platform: iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=flat-square)](#)
[![Privacy: 100% On-Device](https://img.shields.io/badge/Privacy-100%25%20On--Device-green.svg?style=flat-square)](#-privacy-first-architecture)
[![Swift: 5.10+](https://img.shields.io/badge/Swift-5.10+-orange.svg?style=flat-square)](#)

Moody is a privacy-focused, mood-aware personal journal designed to surface the small, quiet wins you walk past every day. Instead of forcing repetitive daily streaks or step counts, Moody utilizes on-device intelligence to read between the lines of your natural, free-form writing—automatically recognizing and awarding milestones like prioritizing sleep, connecting with a friend, or practicing mindfulness.

[Website](https://moody-journal.github.io/) • [Coming Soon to iOS](#)

## Prerequisites

- iPhone running iOS 26 or later with an A17 Pro chip or higher
- Mac running macOS Tahoe or later with an M1 chip or higher



## Features

- **Free-Form Journaling:** A dark, calm, minimal UI designed to clear distraction and bring your thoughts forward. Entries support text, audio recordings, images, locations, and ambient soundtracking.
- **On-Device Milestones & Achievements:** Moody analyzes your writing locally to highlight real achievements hidden in plain sight, rewarding you with beautifully designed, interactive 3D medals.
- **The Mood Meter:** An interactive, fluidly morphing canvas that responds and breathes in real-time to help you visually log your current state of mind before writing.
- **Guided Box-Breathing:** A built-in calming cycle (inhale, pause, exhale, rest) to ground your nervous system and help you arrive before you dive into writing.
- **Weather Insights & Trends:** Spot patterns and triggers over time without invasive metrics, helping you appreciate the quiet days and notice your long-term growth.

## Privacy-First Architecture

Moody is built on a foundational promise: **your most private thoughts never leave your device.** 

- **Apple Intelligence Integration:** Achievement detection, semantic extraction, and text insights are powered entirely by local Apple Intelligence models. No external API calls are made with your words.
- **Zero Tracking:** No user accounts, no sign-ins, and zero third-party analytics SDKs. 
- **Data Ownership:** Data is kept strictly in local storage (CoreData/SwiftData) and safely secured inside your personal iCloud container via CloudKit, fully governed by your iOS system settings.

# 🚀 Terraform Infrastructure for Image Generator Platform

Welcome to the Terraform configuration for **Image Generator Platform**!

You can access the application here: 🌐 [Link to Platform](https://happy-forest-063939003.6.azurestaticapps.net/).

This folder contains the Infrastructure as Code (IaC) definitions and functions code for deploying the backend and frontend services required by the platform. The platform itself is a web application built with **Next.js**, **TypeScript**, **Tailwind CSS**, and **React Hooks**, allowing users to upload images, input prompts, and generate AI-powered shirt designs.

---

## 📦 Project Overview

**Image Generator Platform** is a modern web application where users can:

- Upload images
- Generate customized shirt designs powered by AI

The Terraform configuration here sets up the essential cloud resources needed to run this application.

---

## ☁️ Services Provisioned with Terraform

This Terraform code defines and deploys the following Azure services:

- **Azure Static Web App**  
  Hosts the Next.js frontend for fast, secure, and scalable delivery.
  
- **Azure Function App**  
  Handles serverless backend operations, including AI image generation requests.
  
- **Azure Storage Account**  
  Stores uploaded images, generated designs, and any necessary static assets.


## 📜 License

This project is licensed under the [MIT License](LICENSE).

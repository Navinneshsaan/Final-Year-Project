# Development of an Early Warning Pipeline Rupture Detection System
**Using Negative Pressure Wave and Machine Learning Analysis**

This repository contains the physical simulation, deep learning architecture, and interactive digital twin dashboard developed for an Early Warning Pipeline Rupture Detection System. 

## 📌 Project Overview
Current industrial pipeline monitoring relies on Mass Balancing, which suffers from high latency. This project solves that by utilizing **Negative Pressure Wave (NPW)** analysis paired with a **Long Short-Term Memory (LSTM)** neural network to detect and localize ruptures in real-time.

## ⚙️ Physics Engine: MATLAB Simscape (50km Methane Gas Pipeline)
<img width="1280" height="495" alt="NPW Model" src="https://github.com/user-attachments/assets/ca0008ff-1b22-49ef-9132-0502018171e5" />

## 🧠 AI Architecture: Tuned LSTM
<img width="1246" height="447" alt="Tuned LSTM" src="https://github.com/user-attachments/assets/3ee777ff-9efb-45a4-a6d4-c6c8ef7656e5" />

## 📈 Performance: Achieved 70.33% validation accuracy on raw, unfiltered 10Hz acoustic transient data.
<img width="1714" height="906" alt="LSTM Training Model" src="https://github.com/user-attachments/assets/2cc20668-184a-476b-bb2b-d5d3296da24b" />

## 📸 Interactive Dashboard
<img width="945" height="677" alt="dashboard_demo" src="https://github.com/user-attachments/assets/769919ee-fe76-487e-b626-93680cfa5247" />

## Repository Structure
* `/models`: Contains the Simscape digital twin and the trained LSTM `.mat` file.
* `/scripts`: Automated dataset generation and hyperparameter tuning sweeps.
* `/dashboard`: The live diagnostic UI.

## How to Run
1. Ensure you have MATLAB R2023a (or newer) with the **Deep Learning Toolbox** and **Simscape** installed.
2. Clone this repository.
3. Run `FYP_Live_Dashboard.m` to launch the interactive UI.

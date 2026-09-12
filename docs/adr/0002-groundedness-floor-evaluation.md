# ADR-0002: Groundedness Floor Threshold (Score >= 0.85) for Clinical AI Completions

**Status:** Accepted  
**Date:** 2026-06-30  
**Lead Architect:** William Free Hall (Free) <whall4.wh@gmail.com>

## 1. Context & Operational Challenge
In clinical decision support, ungrounded hallucinations present critical diagnostic risks. We must intercept and reject any response that extrapolates beyond retrieved context.

## 2. Options Considered
* **Option A: Post-Hoc Human Review Only**
  - *Evaluation:* Safe, but creates high physician review friction and prevents real-time automated assistant operations.
* **Option B: Automated Groundedness Gate with Hard Threshold (>= 0.85)**
  - *Evaluation:* Evaluates sentence-level claim alignment against retrieved context vectors; rejects any payload scoring below 0.85 with a fallback refusal.

## 3. Decision & Trade-Off Accepted
We adopted **Option B (Groundedness Floor)**.  
**Trade-Off Accepted:** Incurs ~40ms evaluation overhead before streaming response to client; prevents clinical hallucination propagation.

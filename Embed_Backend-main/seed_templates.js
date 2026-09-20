/**
 * seed_templates.js
 *
 * Seeds BOTTOM_SHEET_TEMPLATES from the frontend constants as system templates in the database.
 * Uses the admin REST API directly (same as the dashboard).
 *
 * Usage:
 *   node seed_templates.js
 *
 * Requirements:
 *   - Backend must be running on http://localhost:4000
 *   - Set ADMIN_SESSION_TOKEN below (copy from browser devtools → Application → Cookies → token)
 */

const axios = require('axios');

// ─── CONFIG ───────────────────────────────────────────────────────────────────
const API_BASE       = 'http://localhost:4000/api/v1';
const SESSION_TOKEN  = process.env.ADMIN_TOKEN || ''; // Set via env: ADMIN_TOKEN=xxx node seed_templates.js

if (!SESSION_TOKEN) {
    console.error('❌ Please set ADMIN_TOKEN env var:');
    console.error('   ADMIN_TOKEN=your_token node seed_templates.js');
    process.exit(1);
}

const headers = {
    'Content-Type': 'application/json',
    'Cookie': `token=${SESSION_TOKEN}`,
};

// ─── TEMPLATE DATA ────────────────────────────────────────────────────────────
// Derived from dashboard/src/lib/bottomSheetTemplates.ts
const SYSTEM_TEMPLATES = [
    {
        name: 'Cart Value Increase',
        type: 'bottomsheet',
        category: 'marketing',
        description: 'Encourage users to add more items to cart for free delivery. Includes progress bar and motivational messaging.',
        tags: ['ecommerce', 'cart', 'delivery', 'progress'],
        thumbnail: null,
        is_system: true,
        config: {
            type: 'bottomsheet',
            height: 'auto',
            minHeight: 280,
            maxHeight: 400,
            dragHandle: true,
            swipeToDismiss: true,
            backgroundColor: '#FFFFFF',
            borderRadius: { topLeft: 24, topRight: 24 },
            overlay: { enabled: true, opacity: 0.5, color: '#000000', dismissOnClick: true },
        },
        layers: [
            { id: 'bs1-container', type: 'container', name: 'Bottom Sheet Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 360, height: 'auto' }, content: {}, style: { backgroundColor: '#FFFFFF', borderRadius: 24, padding: { top: 24, right: 20, bottom: 24, left: 20 }, layout: 'stack', gap: 16 }, children: ['bs1-progress', 'bs1-text', 'bs1-subtext', 'bs1-cta'] },
            { id: 'bs1-progress', type: 'progress-bar', name: 'Cart Progress Bar', parent: 'bs1-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 8 }, content: { value: 150, max: 300, showPercentage: false }, style: { backgroundColor: '#22C55E', borderRadius: 4 }, children: [] },
            { id: 'bs1-text', type: 'text', name: 'Progress Text', parent: 'bs1-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: '₹150 away from free delivery', fontSize: 14, fontWeight: 'semibold', textColor: '#111827', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs1-subtext', type: 'text', name: 'Description', parent: 'bs1-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: "You're halfway there! Add more items to unlock free delivery.", fontSize: 13, fontWeight: 'normal', textColor: '#6B7280', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs1-cta', type: 'button', name: 'Add Items Button', parent: 'bs1-container', visible: true, locked: false, zIndex: 4, position: { x: 0, y: 0 }, size: { width: 'auto', height: 48 }, content: { label: 'Add Items', textColor: '#FFFFFF', buttonStyle: 'primary', action: { type: 'deeplink', url: '/products' } }, style: { backgroundColor: '#22C55E', borderRadius: 10 }, children: [] }
        ],
    },
    {
        name: 'Daily Goal Motivation',
        type: 'bottomsheet',
        category: 'onboarding',
        description: 'Motivate users to complete their daily goal with progress visualization and encouraging copy.',
        tags: ['engagement', 'gamification', 'progress', 'motivation'],
        thumbnail: null,
        is_system: true,
        config: { type: 'bottomsheet', height: 'auto', minHeight: 420, dragHandle: true, swipeToDismiss: true, backgroundColor: '#FFFFFF', borderRadius: { topLeft: 24, topRight: 24 }, overlay: { enabled: true, opacity: 0.6, blur: 4, color: '#000000', dismissOnClick: true } },
        layers: [
            { id: 'bs2-container', type: 'container', name: 'Bottom Sheet Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 360, height: 'auto' }, content: {}, style: { backgroundColor: '#FFFFFF', borderRadius: 24, padding: { top: 32, right: 24, bottom: 32, left: 24 }, layout: 'stack', gap: 16, alignItems: 'center' }, children: ['bs2-title', 'bs2-desc', 'bs2-cta'] },
            { id: 'bs2-title', type: 'text', name: 'Title', parent: 'bs2-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: "You're 75% to your daily goal! 🎯", fontSize: 18, fontWeight: 'bold', textColor: '#111827', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs2-desc', type: 'text', name: 'Description', parent: 'bs2-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Just 5 more minutes to reach your daily target!', fontSize: 14, fontWeight: 'normal', textColor: '#6B7280', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs2-cta', type: 'button', name: 'Continue Button', parent: 'bs2-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 48 }, content: { label: 'Continue', textColor: '#FFFFFF', buttonStyle: 'primary' }, style: { backgroundColor: '#6366F1', borderRadius: 10 }, children: [] }
        ],
    },
    {
        name: 'Limited Time Offer',
        type: 'bottomsheet',
        category: 'marketing',
        description: 'Create urgency with time-limited offers and countdown timer.',
        tags: ['promotion', 'urgency', 'countdown', 'offer'],
        thumbnail: null,
        is_system: true,
        config: { type: 'bottomsheet', height: 'auto', dragHandle: true, swipeToDismiss: true, backgroundColor: '#FFFFFF', borderRadius: { topLeft: 24, topRight: 24 }, overlay: { enabled: true, opacity: 0.7, blur: 2, color: '#000000', dismissOnClick: false } },
        layers: [
            { id: 'bs3-container', type: 'container', name: 'Bottom Sheet Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 360, height: 'auto' }, content: {}, style: { backgroundColor: '#FFFFFF', borderRadius: 24, padding: { top: 20, right: 20, bottom: 20, left: 20 }, layout: 'stack', gap: 16 }, children: ['bs3-title', 'bs3-desc', 'bs3-cta'] },
            { id: 'bs3-title', type: 'text', name: 'Title', parent: 'bs3-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Get 30% off on all flights! ✈️', fontSize: 20, fontWeight: 'bold', textColor: '#111827', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs3-desc', type: 'text', name: 'Description', parent: 'bs3-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Limited time offer! Book before the deal expires.', fontSize: 14, fontWeight: 'normal', textColor: '#6B7280', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs3-cta', type: 'button', name: 'Book Now Button', parent: 'bs3-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 48 }, content: { label: 'Book Now', textColor: '#FFFFFF', buttonStyle: 'primary', action: { type: 'deeplink', url: '/flights' } }, style: { backgroundColor: '#EF4444', borderRadius: 8 }, children: [] }
        ],
    },
    {
        name: 'Festive Reward Offer',
        type: 'bottomsheet',
        category: 'marketing',
        description: 'Celebrate festivals with special rewards and coin offers for user engagement.',
        tags: ['festive', 'rewards', 'coins', 'gamification'],
        thumbnail: null,
        is_system: true,
        config: { type: 'bottomsheet', height: 'auto', dragHandle: true, swipeToDismiss: true, backgroundColor: '#FEF3C7', borderRadius: { topLeft: 24, topRight: 24 }, overlay: { enabled: true, opacity: 0.5, color: '#000000', dismissOnClick: true } },
        layers: [
            { id: 'bs4-container', type: 'container', name: 'Bottom Sheet Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 360, height: 'auto' }, content: {}, style: { backgroundColor: '#FEF3C7', borderRadius: 24, padding: { top: 24, right: 20, bottom: 24, left: 20 }, layout: 'stack', gap: 16 }, children: ['bs4-title', 'bs4-desc', 'bs4-cta'] },
            { id: 'bs4-title', type: 'text', name: 'Title', parent: 'bs4-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Diwali Special! 🪔', fontSize: 22, fontWeight: 'bold', textColor: '#92400E', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs4-desc', type: 'text', name: 'Description', parent: 'bs4-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Complete your first transaction and get 500 coins instantly!', fontSize: 14, fontWeight: 'normal', textColor: '#78350F', textAlign: 'center' }, style: {}, children: [] },
            { id: 'bs4-cta', type: 'button', name: 'Claim Button', parent: 'bs4-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 52 }, content: { label: 'Claim Reward 🎁', textColor: '#FFFFFF', buttonStyle: 'primary', action: { type: 'deeplink', url: '/rewards' } }, style: { backgroundColor: '#F59E0B', borderRadius: 12 }, children: [] }
        ],
    },
    {
        name: 'Onboarding Welcome',
        type: 'modal',
        category: 'onboarding',
        description: 'A clean welcome modal for new users explaining the app value proposition.',
        tags: ['onboarding', 'welcome', 'first-time'],
        thumbnail: null,
        is_system: true,
        config: { type: 'modal', width: 340, roundness: 20, overlay: { enabled: true, opacity: 0.6, dismissOnClick: true } },
        layers: [
            { id: 'modal1-container', type: 'container', name: 'Modal Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 340, height: 'auto' }, content: {}, style: { backgroundColor: '#FFFFFF', borderRadius: 20, padding: { top: 32, right: 24, bottom: 28, left: 24 }, layout: 'stack', gap: 16, alignItems: 'center' }, children: ['modal1-title', 'modal1-desc', 'modal1-cta'] },
            { id: 'modal1-title', type: 'text', name: 'Title', parent: 'modal1-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Welcome to the App! 👋', fontSize: 22, fontWeight: 'bold', textColor: '#111827', textAlign: 'center' }, style: {}, children: [] },
            { id: 'modal1-desc', type: 'text', name: 'Description', parent: 'modal1-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Discover all the features that help you save time and achieve your goals.', fontSize: 14, fontWeight: 'normal', textColor: '#6B7280', textAlign: 'center' }, style: {}, children: [] },
            { id: 'modal1-cta', type: 'button', name: 'Get Started Button', parent: 'modal1-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 48 }, content: { label: "Let's Get Started", textColor: '#FFFFFF', buttonStyle: 'primary' }, style: { backgroundColor: '#6366F1', borderRadius: 12 }, children: [] }
        ],
    },
    {
        name: 'Rating Request',
        type: 'modal',
        category: 'feedback',
        description: 'Ask satisfied users to rate the app. Shows after a positive interaction.',
        tags: ['feedback', 'rating', 'nps', 'review'],
        thumbnail: null,
        is_system: true,
        config: { type: 'modal', width: 320, roundness: 20, overlay: { enabled: true, opacity: 0.6, dismissOnClick: true } },
        layers: [
            { id: 'modal2-container', type: 'container', name: 'Modal Container', parent: null, visible: true, locked: false, zIndex: 0, position: { x: 0, y: 0 }, size: { width: 320, height: 'auto' }, content: {}, style: { backgroundColor: '#FFFFFF', borderRadius: 20, padding: { top: 28, right: 24, bottom: 24, left: 24 }, layout: 'stack', gap: 16, alignItems: 'center' }, children: ['modal2-title', 'modal2-rating', 'modal2-cta'] },
            { id: 'modal2-title', type: 'text', name: 'Title', parent: 'modal2-container', visible: true, locked: false, zIndex: 1, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { text: 'Loving the app? ⭐', fontSize: 20, fontWeight: 'bold', textColor: '#111827', textAlign: 'center' }, style: {}, children: [] },
            { id: 'modal2-rating', type: 'rating', name: 'Star Rating', parent: 'modal2-container', visible: true, locked: false, zIndex: 2, position: { x: 0, y: 0 }, size: { width: 'auto', height: 'auto' }, content: { maxRating: 5, initialRating: 0, starColor: '#F59E0B', emptyColor: '#E5E7EB' }, style: {}, children: [] },
            { id: 'modal2-cta', type: 'button', name: 'Submit Button', parent: 'modal2-container', visible: true, locked: false, zIndex: 3, position: { x: 0, y: 0 }, size: { width: 'auto', height: 44 }, content: { label: 'Submit Rating', textColor: '#FFFFFF', buttonStyle: 'primary' }, style: { backgroundColor: '#F59E0B', borderRadius: 10 }, children: [] }
        ],
    },
];

// ─── SEED FUNCTION ─────────────────────────────────────────────────────────────
async function seedTemplates() {
    console.log('🌱 Seeding system templates...\n');

    let created = 0;
    let skipped = 0;

    for (const template of SYSTEM_TEMPLATES) {
        try {
            const response = await axios.post(
                `${API_BASE}/admin/templates`,
                { ...template, is_system: true },
                { headers, withCredentials: true }
            );

            if (response.data) {
                console.log(`✅ Created: "${template.name}" (${template.type})`);
                created++;
            }
        } catch (error) {
            if (error.response?.status === 409) {
                console.log(`⏭️  Skipped (already exists): "${template.name}"`);
                skipped++;
            } else {
                console.error(`❌ Failed: "${template.name}" →`, error.response?.data?.message || error.message);
            }
        }

        // Small delay between requests
        await new Promise((res) => setTimeout(res, 200));
    }

    console.log(`\n✨ Done! Created: ${created}, Skipped: ${skipped}`);
}

seedTemplates();

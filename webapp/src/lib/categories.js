/* Category catalog — mirrors iOS CategoryColorDefaults + atoms.jsx */
export const CATEGORIES = {
  house:    { emoji: '🏠', label: 'House & Repairs',       hex: '#4F8EF7' },
  garage:   { emoji: '🛠️', label: 'Garage & Tools',        hex: '#FF8A3D' },
  printing: { emoji: '🖨️', label: '3D Printing',           hex: '#20C997' },
  vehicle:  { emoji: '🏍️', label: 'Vehicle & Motorcycle',  hex: '#9B5DE5' },
  tech:     { emoji: '💻', label: 'Tech & Apps',           hex: '#2D9CDB' },
  finance:  { emoji: '📊', label: 'Finance & Admin',       hex: '#2F855A' },
  shopping: { emoji: '🛒', label: 'Shopping & Errands',    hex: '#F72585' },
  travel:   { emoji: '✈️', label: 'Travel & Health',       hex: '#00B4D8' },
};

export function hexA(hex, alpha) {
  const h = hex.replace('#', '');
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}

export const PRIORITY_COLORS = {
  High: '#DC2626',
  Med:  '#FB5607',
  Low:  '#3B82F6',
  Def:  '#9CA3AF',
};

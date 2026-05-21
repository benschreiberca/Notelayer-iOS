import { CATEGORIES, hexA } from '../../lib/categories';

export default function CategoryChip({ categoryId, compact = false }) {
  const cat = CATEGORIES[categoryId];
  if (!cat) return null;

  return (
    <span style={{
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      padding: compact ? '3px 10px' : '4px 11px',
      fontFamily: 'var(--font-body)',
      fontSize: 12,
      fontWeight: 'var(--fw-medium)',
      color: '#374151',
      background: hexA(cat.hex, 0.18),
      border: `0.5px solid ${hexA(cat.hex, 0.30)}`,
      borderRadius: 'var(--radius-full)',
      whiteSpace: 'nowrap',
    }}>
      <span>{cat.emoji}</span>
      <span>{cat.label}</span>
    </span>
  );
}

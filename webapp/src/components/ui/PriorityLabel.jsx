import { PRIORITY_COLORS } from '../../lib/categories';

export default function PriorityLabel({ level }) {
  const color = PRIORITY_COLORS[level] ?? '#9CA3AF';
  return (
    <span style={{
      fontFamily: 'var(--font-body)',
      fontWeight: 'var(--fw-medium)',
      fontSize: 12,
      color,
    }}>
      {level}
    </span>
  );
}

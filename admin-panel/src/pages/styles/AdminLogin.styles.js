import { styled } from '@mui/material/styles';
import { Paper, Typography } from '@mui/material';

export const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(4),
  background: 'rgba(255, 255, 255, 0.9)',
  backdropFilter: 'blur(10px)',
  borderRadius: 16,
  boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
  border: '1px solid rgba(255, 255, 255, 0.18)',
  [theme.breakpoints.up('sm')]: {
    padding: theme.spacing(6),
  },
}));

export const GradientTypography = styled(Typography)(({ theme }) => ({
  background: `linear-gradient(45deg, ${theme.palette.primary.main}, ${theme.palette.secondary.main})`,
  backgroundClip: 'text',
  WebkitBackgroundClip: 'text',
  color: 'transparent',
  fontWeight: 700,
  marginBottom: theme.spacing(4),
}));

export const FormContainer = styled('form')(({ theme }) => ({
  width: '100%',
  marginTop: theme.spacing(1),
}));
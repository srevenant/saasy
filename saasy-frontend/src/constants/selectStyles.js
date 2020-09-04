const STYLES = {
  dark: {
    singleValue: (base) => ({
      ...base,
      color: 'var(--t-solidbg-dark-text)',
      maxWidth: 'inherit'
      // const { maxWidth, position, transform, ...other } = base
      // console.log("MAX", maxWidth, position, transform)
      // other['color'] = 'var(--t-solidbg-dark-text)'
      // return other
    }),
    control: (base) => ({
      ...base,
      outline: 'none',
      borderRadius: '0.5rem',
      paddingLeft: '.2rem',
      margin: '1px',
      backgroundColor: '#3a3b3c', // var(--t-overlay-darken2)',
      backdropFilter: 'blur(10px)',
      border: 'solid 2px transparent',
      boxShadow: 'none',
      minHeight: 'auto',
      padding: '0.125rem 0 0.125rem 0.125rem'
    }),
    placeholder: (base) => ({
      ...base,
      fontStyle: 'italic',
      color: 'gray'
    }),
    option: (base, state) => ({
      ...base,
      backgroundColor: state.isFocused ? 'rgba(255, 255, 255, 0.1)' : 'inherit',
      color: 'var(--t-solidbg-dark-text)',
      padding: '.5rem .4rem .5rem .4rem'
    }),
    input: (base) => ({
      ...base,
      color: 'var(--t-solidbg-dark-text)'
    }),
    dropdownIndicator: (base) => ({
      margin: 0,
      color: 'var(--t-solidbg-dark-text)'
    }),
    indicatorSeparator: (base) => ({}),
    valueContainer: (base) => ({
      ...base,
      padding: 0,
      minHeight: 'auto'
    }),
    menu: (base) => ({
      ...base,
      borderRadius: 0,
      whiteSpace: 'nowrap',
      width: 'auto',
      left: 0,
      color: 'var(--t-transbg-dark-text)',
      backgroundColor: 'var(--t-solidbg-dark)',
      backdropFilter: 'blur(10px)',
      boxShadow: '3px 3px 6px var(--t-primary-a50)',
      padding: 0
    })
  },

  //////////////////////////////////////////////////////////////////////////////
  light: {
    singleValue: (base) => ({
      ...base,
      color: 'var(--t-solidbg-dark-text)',
      maxWidth: 'inherit'
      // const { maxWidth, position, transform, ...other } = base
      // console.log("MAX", maxWidth, position, transform)
      // other['color'] = 'var(--t-solidbg-dark-text)'
      // return other
    }),
    control: (base) => ({
      ...base,
      outline: 'none',
      borderRadius: '0.5rem',
      paddingLeft: '.2rem',
      margin: '1px',
      backdropFilter: 'blur(10px)',
      backgroundColor: '#f3f3f3',
      color: 'var(--t-solidbg-light-text)',
      border: 'solid 2px transparent',
      boxShadow: 'none',
      minHeight: 'auto',
      padding: '0.125rem 0 0.125rem 0.125rem'
    }),
    placeholder: (base) => ({
      ...base,
      fontStyle: 'italic',
      color: 'gray'
    }),
    option: (base, state) => ({
      ...base,
      backgroundColor: state.isFocused ? 'rgba(255, 255, 255, 0.5)' : 'inherit',
      padding: '.5rem .4rem .5rem .4rem'
    }),
    input: (base) => ({
      ...base,
      color: 'var(--t-solidbg-dark-text)'
    }),
    dropdownIndicator: (base) => ({
      color: 'var(--t-solidbg-dark-text)'
    }),
    indicatorSeparator: (base) => ({}),
    valueContainer: (base) => ({
      ...base,
      padding: 0,
      minHeight: 'auto'
    }),
    menu: (base) => ({
      ...base,
      borderRadius: 0,
      whiteSpace: 'nowrap',
      width: 'auto',
      left: 0,
      color: 'var(--t-transbg-light-text)',
      backgroundColor: 'var(--t-solidbg-light-accent)',
      backdropFilter: 'blur(10px)',
      boxShadow: '3px 3px 6px var(--t-primary-a50)',
      padding: 0
    })
  }
}

export function selectStyle(user) {
  const theme = user.settings.theme || 'dark'
  return STYLES[theme]
}

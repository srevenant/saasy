const sizes = [1440, 720, 480]

const backgrounds = [
  { img: 'headway-5QgIuuBxKwM-unsplash' },
  { img: 'dylan-gillis-KdeqA3aTnBY-unsplash' },
  { img: 'room-mt8G98XVxlg-unsplash' },
  { img: 'austin-neill-247047-unsplash' }
  // {img: 'lorenzo-herrera-vHNpBQGxqlg-unsplash' },
  // {img: 'siravit-phiwondee-sz2VFnhlWf8-unsplash' },
]

export function randomBackground() {
  const img = backgrounds[Math.floor(Math.random() * backgrounds.length)]
  return sizes.reduce((acc, size) => {
    acc[size] = `/assets/bgs/${img.img}-1440.jpg`
    return acc
  }, {})
}

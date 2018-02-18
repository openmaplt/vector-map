let defaultType = 'bicycle';
let mapTypes = {
  bicycle: 'b',
  orto: 'o',
  bicycle_hybrid: 'bh'
};
let legendData = {
  leg1: {label: 'Dviračių maršrutai', type: 'line'},
  leg2: {label: 'Dviračių takai atskirti nuo gatvių', type: 'line'},
  leg3: {label: 'Dviračių takai šalia gatvių', type: 'line'},
  leg4: {label: 'Dviračių juostos gatvėse', type: 'line'},
  leg5: {label: 'Siūlomos jungtys tarp dviračių takų', type: 'line'},
  leg6: {label: 'Dviračių stovėjimo vietos', type: 'icon'},
  leg7: {label: 'Dviračių parduotuvės', type: 'icon'},
  leg8: {label: 'Suspaustas oras', type: 'icon'},
  leg9: {label: 'Dviračių nuomos punktas', type: 'icon'}
};
let legendTechUrl = '/doc/bicycle_doc.html';
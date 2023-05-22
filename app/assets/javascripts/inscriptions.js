let inscriptions_table

function modal_disable_inscription(id) {
  $('#modal-disable-inscription #inscription_id').val(id)
  $('#modal-disable-inscription').modal('show')
}

$(document).ready(function(){
  inscriptions_table = $("#inscriptions_table").DataTable({
    'ajax': '/inscriptions',
    'columns': [
      {'data': 'company'},
      {'data': 'name'},
      {'data': 'dni'},
      {'data': 'email'},
      {'data': 'pay_method'},
      {'data': 'exposes_work'},
      {'data': 'actions'}
    ],
    'language': {'url': datatables_lang}
  })

  $("#form-disable-inscription").on("ajax:success", function(event) {
    inscriptions_table.ajax.reload(null,false)
    let msj = JSON.parse(event.detail[2].response)
    noty_alert(msj.status, msj.msg)
    $("#modal-disable-inscription").modal('hide')
  }).on("ajax:error", function(event) {
    console.log(event)
  })


  $("#form-inscription").on("ajax:success", function(event) {
      let msg = JSON.parse(event.detail[2].response)
      noty_alert(msg.status, msg.msg)
      window.location.href = msg.url
    }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    set_input_status_form('form-inscription', 'inscription', msg)
  })
})

function display_transfer_file() {
  let transfer_file = document.querySelector('#inscription_file_transfer')
  if (event.target.value == 'transfer') {
    transfer_file.parentElement.style.display = ''
    transfer_file.required = true
  } else {
    transfer_file.parentElement.style.display = 'none'
    transfer_file.required = false
    transfer_file.value = ''
  }
}
const datatables_lang = "/assets/vendor/datatables/datatables_lang_spa.json";
function noty_alert(type, message, time = 7000) {
  const newNoty = new Noty({
    type: type,
    layout: "topRight",
    timeout: (true, time),
    text: message,
    theme: "bootstrap-v4",
    closeWith: ['click', 'button'],
  }).show();
}

function set_input_status_form( form_id, object_name, msg ){
  // form_id es el id del form
  // object_name es el nombre del modelo 
  let inputs = document.querySelectorAll(`#${form_id} .form-control`)
  let list_ids = []
  let error_msg
  for (let i = 0; i< inputs.length; i++) {
      list_ids[i] = inputs[i].id
  }
  $.each( msg, function( key, value ) {
    if ( value.length > 1 ) {
      error_msg = "<ul class='pl-2'>"
      value.forEach(element =>  error_msg += `<li>${element}</li>` );
      error_msg += '</ul>'
    } else {
      error_msg = value[0]
    }

    $(`#${form_id} #${object_name}_${key}`).addClass('is-invalid')
    document.querySelector(`#${form_id} .${object_name}_${key}`).innerHTML = error_msg
    list_ids = list_ids.filter( element => element != `${object_name}_${key}`)
  })
  console.log( list_ids )
  for (let i = list_ids.length - 1; i >= 0; i--) {
    let input = document.querySelector(`#${form_id} #${list_ids[i]}`)
    input.classList.remove('is-invalid')
    if (document.querySelector(`#${form_id} .${list_ids[i]}`) == null) {
      console.log('!!!!!esto es nulo => ',`#${form_id} .${list_ids[i]}`)
    } else {
      document.querySelector(`#${form_id} .${list_ids[i]}`).textContent = ''
    }

    if ( input.value != '' ) {
      input.classList.add('is-valid')
    }
    
    if ( input.value == '' ) {
      input.classList.remove('is-valid')
    }
  }
}

function setInputDate(_id){
    var _dat = document.querySelector(_id);
    var today = new Date(),
        d = today.getDate(),
        m = today.getMonth()+1, 
        y = today.getFullYear(),
        data;

    if(d < 10){
        d = "0"+d;
    };
    if(m < 10){
        m = "0"+m;
    };

    data = y+"-"+m+"-"+d;
    _dat.value = data;
}

function setInputDateWithValue(_id, _date){
    var _dat = document.querySelector(_id);
    var d = _date.getDate(),
        m = _date.getMonth()+1, 
        y = _date.getFullYear(),
        data;

    if(d < 10){
        d = "0"+d;
    };
    if(m < 10){
        m = "0"+m;
    };

    data = y+"-"+m+"-"+d;
    _dat.value = data;
}

function formatDateAR(_date){
  let data = new Date(`${_date}T00:00:00`)
  return data.toLocaleDateString('es-AR')
}

function clean_form(form_id) {
  $(`#${form_id} .form-control`).removeClass('is-invalid')
  $(`#${form_id} .form-control`).removeClass('is-valid')
  $(`#${form_id}`)[0].reset()
}

function hide_table( table_id ) {
  const table = document.getElementById(table_id)
  if (table.dataset.show == 'show' ) {
    $(`#${table_id}`).hide('slow')
    table.dataset.show = 'hide'
  } else {
     $(`#${table_id}`).show('slow')
     table.dataset.show = 'show'
  }
}

function close_modal( modal_id) {
  $(`#${modal_id}`).modal('hide')
}

  $(document).ready(function() {

    $('#listtab').DataTable({
      scrollY: "10vh",
      scrollCollapse: true,
      paging: false,
      bFilter:false,
      bInfo : false,
      autoWidth: true,
      responsive: true,
      retrieve: true
    });

  });

create or replace function process() returns text as $$
declare
  l_wave integer := 0;
begin
  raise notice 'Pradedame %', clock_timestamp();

  update upiu_baseinai set basin = null, wave = null;

  update upiu_baseinai set basin = -100, wave = 0 where name in ('Nemunas', 'Reizgupis');
  update upiu_baseinai set basin = -101, wave = 0 where name = 'Danė';
  update upiu_baseinai set basin = -102, wave = 0 where name = 'Šventoji' and wikipedia = 'lt:Šventoji';
  update upiu_baseinai set basin = -103, wave = 0 where name = 'Venta';
  update upiu_baseinai set basin = -104, wave = 0 where name in ('Mūša', 'Maučiuvis', 'Viršytis', 'Beržtalis',
    'Plonė', 'Švitinys', 'Šešėvėlė', 'Vilkija', 'Platonis', 'Sidabra', 'Audruvė', 'Virčiuvis', 'Švėtė', 'Šešvelė', 'Yslykis');
  -- Marčiupiai yra du, tai reikia aiškesnių parinkimo sąlygų
  update upiu_baseinai set basin = -104, wave = 0 where name = 'Marčiupys' and st_length(way) > 8000;
  -- Alėjos yra dvi, tai reikia aiškesnių parinkimo sąlygų
  update upiu_baseinai set basin = -104, wave = 0 where name = 'Alėja' and st_length(way) < 15000;
  -- Lankos yra dvi, tai reikia aiškesnių parinkimo sąlygų
  update upiu_baseinai set basin = -104, wave = 0 where name = 'Lanka' and st_length(way) > 10000;
  update upiu_baseinai set basin = -105, wave = 0 where name = 'Nemunėlis';
  update upiu_baseinai set basin = -106, wave = 0 where name = 'Neris';
  update upiu_baseinai set basin = -107, wave = 0 where name = 'Nevėžis';
  update upiu_baseinai set basin = -108, wave = 0 where name in ('Merkys', 'Ditva');
  -- Rausvė, kad prijungtų atskirą Šešupės baseino dalį
  update upiu_baseinai set basin = -109, wave = 0 where name in ('Šešupė', 'Rausvė');

  -- „Trumpi galai“
  update upiu_baseinai set basin = -110, wave = 0 where name in ('Ronžė', 'Rikinė', 'Cypa', 'Lūšis', 'Skutulė', 'Smeltalė', 'Strūna',
    'Smalava', 'Apyvardė', 'Straumenė', /*'Kreivė',*/ 'Pagraužys', 'Vygra', 'Nočia', 'Vydupis', 'Grybingirys', 'Gulbinė',
    'Dysna', 'Birvėta', 'Gauja', 'Laukesa', 'Lukšta', 'Zvikelė', 'Rudupė', 'Uidė', 'Vyžaina', 'Vadakstis', 'Mara', /*'Katra',*/
    'Kamoja', 'Rauda');

  while touch(l_wave) > 0 loop
    l_wave := l_wave + 1;
  end loop;

  raise notice 'Baigiame %', clock_timestamp();

  return 'Tvarka';
end
$$ language plpgsql;

select process();

drop function process();
drop function touch(int);

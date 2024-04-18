
function Population1 = CombinePopulation(OPTIONS, Population1, Population2)

numPuffer1 = ceil(OPTIONS.partition*OPTIONS.popsize);

for i = 1: OPTIONS.popsize - numPuffer1
    Population1(numPuffer1 + i).chrom = Population2(i).chrom;
    Population1(numPuffer1 + i).cost = Population2(i).cost;
end

